From: Jan Synacek <jsynacek@redhat.com>
Subject: [PATCH 1/2] ping,ping6: Add newline to error message.
Date: Wed, 14 Nov 2012 13:57:15 +0100
Message-ID: <1352897836-17603-2-git-send-email-jsynacek@redhat.com>
References: <1352897836-17603-1-git-send-email-jsynacek@redhat.com>
Cc: netdev@vger.kernel.org, Jan Synacek <jsynacek@redhat.com>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38400 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422711Ab2KNM5v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2012 07:57:51 -0500
In-Reply-To: <1352897836-17603-1-git-send-email-jsynacek@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 ping_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ping_common.c b/ping_common.c
index 86dbeaa..1605ca9 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -265,7 +265,7 @@ void common_options(int ch)
 		char *endp;
 		mark = (int)strtoul(optarg, &endp, 10);
 		if (mark < 0 || *endp != '\0') {
-			fprintf(stderr, "mark cannot be negative");
+			fprintf(stderr, "mark cannot be negative\n");
 			exit(2);
 		}
 		options |= F_MARK;
-- 
1.7.11.7
