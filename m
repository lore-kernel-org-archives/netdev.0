From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ip-link: Align usage at [link-netns ID] line
Date: Sat,  4 Apr 2015 17:06:19 +0300
Message-ID: <1428156379-9662-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:37786 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752648AbbDDOSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 10:18:22 -0400
Received: by wiaa2 with SMTP id a2so165710826wia.0
        for <netdev@vger.kernel.org>; Sat, 04 Apr 2015 07:18:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Output of the usage was shifted be cause of missing TAB

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/iplink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 5893ee4..e6f30e9 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -72,7 +72,7 @@ void iplink_usage(void)
 	fprintf(stderr, "	                  [ mtu MTU ]\n");
 	fprintf(stderr, "	                  [ netns PID ]\n");
 	fprintf(stderr, "	                  [ netns NAME ]\n");
-	fprintf(stderr, "                         [ link-netnsid ID ]\n");
+	fprintf(stderr, "	                  [ link-netnsid ID ]\n");
 	fprintf(stderr, "			  [ alias NAME ]\n");
 	fprintf(stderr, "	                  [ vf NUM [ mac LLADDR ]\n");
 	fprintf(stderr, "				   [ vlan VLANID [ qos VLAN-QOS ] ]\n");
-- 
2.3.1
