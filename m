From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ip xfrm mon: Add objects list to the usage output
Date: Sat, 14 Feb 2015 20:07:44 +0200
Message-ID: <1423937264-9298-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:51374 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754136AbbBNSSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2015 13:18:51 -0500
Received: by mail-lb0-f169.google.com with SMTP id p9so20878249lbv.0
        for <netdev@vger.kernel.org>; Sat, 14 Feb 2015 10:18:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/xfrm_monitor.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ip/xfrm_monitor.c b/ip/xfrm_monitor.c
index 79453e4..0b58d24 100644
--- a/ip/xfrm_monitor.c
+++ b/ip/xfrm_monitor.c
@@ -36,7 +36,8 @@ static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip xfrm monitor [ all | LISTofXFRM-OBJECTS ]\n");
+	fprintf(stderr, "Usage: ip xfrm monitor [ all | OBJECTS | help ]\n");
+	fprintf(stderr, "OBJECTS := { acquire | expire | SA | aevent | policy | report }\n");
 	exit(-1);
 }
 
-- 
2.2.2
