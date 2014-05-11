From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH] ipnetns: fix misprint in an error message
Date: Sun, 11 May 2014 12:21:26 +0300
Message-ID: <1399800086-18661-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: netdev@vger.kernel.org,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:55933 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbaEKJVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 05:21:47 -0400
Received: by mail-wi0-f182.google.com with SMTP id r20so3147318wiv.15
        for <netdev@vger.kernel.org>; Sun, 11 May 2014 02:21:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 ip/ipnetns.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 1d8d3dc..2b3b2e1 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -435,7 +435,7 @@ static int netns_add(int argc, char **argv)
 	/* Create the filesystem state */
 	fd = open(netns_path, O_RDONLY|O_CREAT|O_EXCL, 0);
 	if (fd < 0) {
-		fprintf(stderr, "Cannot not create namespace file \"%s\": %s\n",
+		fprintf(stderr, "Cannot create namespace file \"%s\": %s\n",
 			netns_path, strerror(errno));
 		return -1;
 	}
-- 
1.8.3.2
