#!/bin/sh
# Usage: ./create-application.sh <repository_name>
# Create a new repo,  Spring Boot project, and Github Action

cd $(pwd)/.. || exit

# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <repository_name>"
  exit 1
fi

REPO_NAME=$1
ACTION_FILE=".github/workflows/maven.yml"

echo "Creating a new github repo : $REPO_NAME"

# Create a new repository in Github and make a local copy
gh repo create $REPO_NAME --public --clone
cd $REPO_NAME || exit

# Create a new Spring Boot project and push the code
curl https://start.spring.io/starter.tgz -d dependencies=web,actuator,devtools -d type=maven-project -d language=java -d bootVersion=3.4.2 -d groupId=com.example -d artifactId=springboot-github-action -d name=springboot-github-action -d packageName=com.example.github.action -d baseDir=. | tar -xzvf -
git add --all
git commit -m "add spring boot code"
git push --set-upstream origin master

# Create the Github Workflow directory and download the Github Action
mkdir -p .github/workflows
curl -o $ACTION_FILE https://raw.githubusercontent.com/actions/starter-workflows/refs/heads/main/ci/maven.yml

# Use sed to replace '$default-branch' with '**'
sed -i 's/\$default-branch/"\*\*"/g' $ACTION_FILE

# remove the last 3 lines of the github action file.
sed -i '/# Optional:/,$d' $ACTION_FILE

git add --all
git commit -m "add github action"
git push