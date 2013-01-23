From: Jan Synacek <jsynacek@redhat.com>
Subject: [PATCH 2/2] ninfod: Make -v exit correctly.
Date: Wed, 23 Jan 2013 14:37:45 +0100
Message-ID: <1358948265-20867-3-git-send-email-jsynacek@redhat.com>
References: <1358948265-20867-1-git-send-email-jsynacek@redhat.com>
Cc: netdev@vger.kernel.org, Jan Synacek <jsynacek@redhat.com>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14281 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754530Ab3AWNh4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 08:37:56 -0500
In-Reply-To: <1358948265-20867-1-git-send-email-jsynacek@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jan Synacek <jsynacek@redhat.com>
---
 ninfod/ninfod.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/ninfod/ninfod.c b/ninfod/ninfod.c
index 58b15aa..52cf446 100644
--- a/ninfod/ninfod.c
+++ b/ninfod/ninfod.c
@@ -639,12 +639,15 @@ int main (int argc, char **argv)
 
 	parse_args(argc, argv);
 
-	if (opt_h || opt_v)
-		print_copying();
 	if (opt_h) {
+		print_copying();
 		print_usage();
 		exit(1);
 	}
+	if (opt_v) {
+		print_copying();
+		return 0;
+	}
 
 	limit_capabilities();
 
-- 
1.8.1
