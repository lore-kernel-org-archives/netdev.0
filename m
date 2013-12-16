From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH] genl: fix a typo in help message of ctrl
Date: Mon, 16 Dec 2013 12:38:10 +0900
Message-ID: <1387165090-5130-1-git-send-email-yamato@redhat.com>
Cc: yamato@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9136 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752255Ab3LPDiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Dec 2013 22:38:24 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rBG3cO3s030803
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 22:38:24 -0500
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
1.8.3.1
