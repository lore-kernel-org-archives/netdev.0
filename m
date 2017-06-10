From: Rami Rosen <rami.rosen@intel.com>
Subject: [PATCH net-next] net/packet: remove unneeded declaraion of tpacket_snd().
Date: Sat, 10 Jun 2017 03:22:48 +0300
Message-ID: <1497054168-5444-1-git-send-email-rami.rosen@intel.com>
Cc: netdev@vger.kernel.org, Rami Rosen <rami.rosen@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9881 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751797AbdFJH2m (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 10 Jun 2017 03:28:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes unneeded forward declaration of tpacket_snd()
in net/packet/af_packet.c.

Signed-off-by: Rami Rosen <rami.rosen@intel.com>
---
 net/packet/af_packet.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 82ca49fba336..f9349a495caf 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -188,7 +188,6 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 #define BLOCK_PRIV(x)		((void *)((char *)(x) + BLOCK_O2PRIV(x)))
 
 struct packet_sock;
-static int tpacket_snd(struct packet_sock *po, struct msghdr *msg);
 static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		       struct packet_type *pt, struct net_device *orig_dev);
 
-- 
2.4.11
