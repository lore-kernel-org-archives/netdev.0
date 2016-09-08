From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH iproute2] tuntap: Add name attribute to usage text
Date: Thu,  8 Sep 2016 14:56:34 +0200
Message-ID: <285078d628b8144a50f15a23e4ba7a7e4306f48e.1473338775.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:34382 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932338AbcIHM4h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 08:56:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 ip/iptuntap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iptuntap.c b/ip/iptuntap.c
index 34fb0cf..451f7f0 100644
--- a/ip/iptuntap.c
+++ b/ip/iptuntap.c
@@ -39,7 +39,7 @@ static void usage(void)
 {
 	fprintf(stderr, "Usage: ip tuntap { add | del | show | list | lst | help } [ dev PHYS_DEV ]\n");
 	fprintf(stderr, "          [ mode { tun | tap } ] [ user USER ] [ group GROUP ]\n");
-	fprintf(stderr, "          [ one_queue ] [ pi ] [ vnet_hdr ] [ multi_queue ]\n");
+	fprintf(stderr, "          [ one_queue ] [ pi ] [ vnet_hdr ] [ multi_queue ] [ name NAME ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: USER  := { STRING | NUMBER }\n");
 	fprintf(stderr, "       GROUP := { STRING | NUMBER }\n");
-- 
2.5.5
