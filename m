From: matthew@walster.org
Subject: [PATCH 1/2] net: ethernet: clean out braces / old code (found via checkpatch)
Date: Tue,  2 Oct 2012 12:41:44 +0100
Message-ID: <1349178105-28269-2-git-send-email-matthew@walster.org>
References: <1349178105-28269-1-git-send-email-matthew@walster.org>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Matthew Walster <matthew@walster.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349178105-28269-1-git-send-email-matthew@walster.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthew Walster <matthew@walster.org>

Remove an old commented out piece of code.
Remove an if(true) statement.
Remove a set of braces that weren't strictly necessary.

All found by running checkpatch.pl against the code.

Signed-off-by: Matthew Walster <matthew@walster.org>
---
 net/ethernet/eth.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 4efad53..a9f8531 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -178,11 +178,8 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	 *      seems to set IFF_PROMISC.
 	 */
 
-	else if (1 /*dev->flags&IFF_PROMISC */ ) {
-		if (unlikely(!ether_addr_equal_64bits(eth->h_dest,
-						      dev->dev_addr)))
-			skb->pkt_type = PACKET_OTHERHOST;
-	}
+	else if (unlikely(!ether_addr_equal_64bits(eth->h_dest, dev->dev_addr)))
+		skb->pkt_type = PACKET_OTHERHOST;
 
 	/*
 	 * Some variants of DSA tagging don't have an ethertype field
-- 
1.7.10.4
