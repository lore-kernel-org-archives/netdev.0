From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1] tipc: make sure IPv6 header fits in skb headroom
Date: Mon, 14 Mar 2016 09:43:52 +0100
Message-ID: <1457945032-30547-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Richard Alpe <richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:60659 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933863AbcCNIpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 04:45:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Expand headroom further in order to be able to fit the larger IPv6
header. Prior to this patch this caused a skb under panic for certain
tipc packets when using IPv6 UDP bearer(s).

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/udp_media.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index 49b3c2e..6364cff 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -53,7 +53,7 @@
 /* IANA assigned UDP port */
 #define UDP_PORT_DEFAULT	6118
 
-#define UDP_MIN_HEADROOM        28
+#define UDP_MIN_HEADROOM        48
 
 /**
  * struct udp_media_addr - IP/UDP addressing information
-- 
2.1.4
