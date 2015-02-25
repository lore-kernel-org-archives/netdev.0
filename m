From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] bridge: Show state names in the 'link help' print
Date: Thu, 26 Feb 2015 01:56:33 +0200
Message-ID: <1424908593-4524-1-git-send-email-vadim4j@gmail.com>
Cc: netdev@vger.kernel.org, Vadim Kochan <vadim4j@gmail.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:35446 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753119AbbBZAHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 19:07:54 -0500
Received: by labgm9 with SMTP id gm9so7625381lab.2
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 16:07:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 bridge/link.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/bridge/link.c b/bridge/link.c
index a7bd85f..7f1ec70 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -228,6 +228,12 @@ static void usage(void)
 	fprintf(stderr,	"                               [ flood {on | off} ]\n");
 	fprintf(stderr, "                               [ hwmode {vepa | veb} ]\n");
 	fprintf(stderr, "       bridge link show [dev DEV]\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "STATE := { 0 | disabled   |\n");
+	fprintf(stderr, "           1 | listening  |\n");
+	fprintf(stderr, "           2 | learning   |\n");
+	fprintf(stderr, "           3 | forwarding |\n");
+	fprintf(stderr, "           4 | blocking }\n");
 	exit(-1);
 }
 
-- 
2.2.2
