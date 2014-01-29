From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH resend] genl: fix a typo in help message of ctrl
Date: Wed, 29 Jan 2014 20:30:15 +0900
Message-ID: <1390995015-30634-1-git-send-email-yamato@redhat.com>
Cc: yamato@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26797 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751425AbaA2Lab (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jan 2014 06:30:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 genl/ctrl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/genl/ctrl.c b/genl/ctrl.c
index 7c42578..3546129 100644
--- a/genl/ctrl.c
+++ b/genl/ctrl.c
@@ -399,7 +399,7 @@ static int parse_ctrl(struct genl_util *a, int argc, char **argv)
 	if (matches(*argv, "help") == 0)
 		return usage();
 
-	fprintf(stderr, "ctrl command \"%s\" is unknown, try \"ctrl -help\".\n",
+	fprintf(stderr, "ctrl command \"%s\" is unknown, try \"ctrl help\".\n",
 		*argv);
 
 	return -1;
-- 
1.8.5.3
