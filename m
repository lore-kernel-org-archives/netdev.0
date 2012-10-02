From: matthew@walster.org
Subject: [PATCH 2/2] net: ethernet: Remove obsolete comment
Date: Tue,  2 Oct 2012 12:41:45 +0100
Message-ID: <1349178105-28269-3-git-send-email-matthew@walster.org>
References: <1349178105-28269-1-git-send-email-matthew@walster.org>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Matthew Walster <matthew@walster.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:54854 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514Ab2JBLmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 07:42:05 -0400
In-Reply-To: <1349178105-28269-1-git-send-email-matthew@walster.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Walster <matthew@walster.org>

The deleted comment was related to code I've just removed in the previous patch.
---
 net/ethernet/eth.c |    8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index a9f8531..7d72108 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -170,14 +170,6 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 			skb->pkt_type = PACKET_MULTICAST;
 	}
 
-	/*
-	 *      This ALLMULTI check should be redundant by 1.4
-	 *      so don't forget to remove it.
-	 *
-	 *      Seems, you forgot to remove it. All silly devices
-	 *      seems to set IFF_PROMISC.
-	 */
-
 	else if (unlikely(!ether_addr_equal_64bits(eth->h_dest, dev->dev_addr)))
 		skb->pkt_type = PACKET_OTHERHOST;
 
-- 
1.7.10.4
