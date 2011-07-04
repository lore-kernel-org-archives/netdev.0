From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: rionet: Use is_multicast_ether_addr
Date: Mon,  4 Jul 2011 11:54:54 +0200
Message-ID: <1309773294-25395-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:42948 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754151Ab1GDJy4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 05:54:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/rionet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index 77c5092..bcdc54f 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -190,7 +190,7 @@ static int rionet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		return NETDEV_TX_BUSY;
 	}
 
-	if (eth->h_dest[0] & 0x01) {
+	if (is_multicast_ether_addr(eth->h_dest)) {
 		for (i = 0; i < RIO_MAX_ROUTE_ENTRIES(rnet->mport->sys_size);
 				i++)
 			if (rionet_active[i])
-- 
1.7.5.4

