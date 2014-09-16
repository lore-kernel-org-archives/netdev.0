From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ip tuntap: Added missing commands in usage
Date: Wed, 17 Sep 2014 00:24:11 +0300
Message-ID: <1410902651-9240-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:56368 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752512AbaIPVc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 17:32:27 -0400
Received: by mail-lb0-f177.google.com with SMTP id l4so650806lbv.36
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 14:32:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

show, list, lst and help commands were not printed in usage.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/iptuntap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iptuntap.c b/ip/iptuntap.c
index 2391af2..0ce64a6 100644
--- a/ip/iptuntap.c
+++ b/ip/iptuntap.c
@@ -36,7 +36,7 @@ static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip tuntap { add | del } [ dev PHYS_DEV ] \n");
+	fprintf(stderr, "Usage: ip tuntap { add | del | show | list | lst | help } [ dev PHYS_DEV ] \n");
 	fprintf(stderr, "          [ mode { tun | tap } ] [ user USER ] [ group GROUP ]\n");
 	fprintf(stderr, "          [ one_queue ] [ pi ] [ vnet_hdr ] [ multi_queue ]\n");
 	fprintf(stderr, "\n");
-- 
2.1.0
