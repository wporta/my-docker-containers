#!/bin/bash

# Variables
CONTAINER_NAME="gitlab"
IMAGE_NAME="gitlab/gitlab-ce:latest"
BACKUP_DIR="./backup"  # Change this to your desired backup directory on the host
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Function to create a backup
backup_gitlab() {
  echo "Creating GitLab backup..."
  docker exec -t $CONTAINER_NAME gitlab-backup create

  # Copy backup to host machine
  echo "Copying backup to $BACKUP_DIR"
  docker cp $CONTAINER_NAME:/var/opt/gitlab/backups "$BACKUP_DIR"/backup_$TIMESTAMP
}

# Function to pull the latest GitLab CE image
update_gitlab_image() {
  echo "Pulling the latest GitLab CE image..."
  docker pull $IMAGE_NAME
}

# Function to stop and remove the current container
stop_remove_container() {
  echo "Stopping and removing the existing GitLab container..."
  docker stop $CONTAINER_NAME
  docker rm $CONTAINER_NAME
}

# Function to start the updated GitLab container
start_new_container() {
  echo "Starting the updated GitLab container..."
  docker-compose up -d
}

# Main script execution
echo "Starting GitLab CE update process..."

# 1. Backup GitLab
backup_gitlab

# 2. Pull latest GitLab CE image
update_gitlab_image

# 3. Stop and remove old container
stop_remove_container

# 4. Start new container with updated image
start_new_container

echo "GitLab CE update process complete!"

# Check GitLab version
echo "Verifying the update..."
docker exec -it $CONTAINER_NAME gitlab-rake gitlab:env:info
