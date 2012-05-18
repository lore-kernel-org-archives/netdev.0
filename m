From: Jeffrin Jose <ahiliation@yahoo.co.in>
Subject: [PATCH 1/1]net:ethernet:fixed a coding style issue relating space.
Date: Sat, 19 May 2012 03:15:37 +0530
Message-ID: <1337377537-4636-1-git-send-email-ahiliation@yahoo.co.in>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ahiliation@yahoo.co.in
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed a coding style issue relating to  space found
by checkpatch.pl tool in net/ethernet/eth.c

Signed-off-by: Jeffrin Jose <ahiliation@yahoo.co.in>
---
 net/ethernet/eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 36e5880..c847aa6 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -178,7 +178,7 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	 *      seems to set IFF_PROMISC.
 	 */
 
-	else if (1 /*dev->flags&IFF_PROMISC */ ) {
+	else if (1 /*dev->flags&IFF_PROMISC */) {
 		if (unlikely(!ether_addr_equal_64bits(eth->h_dest,
 						      dev->dev_addr)))
 			skb->pkt_type = PACKET_OTHERHOST;
-- 
1.7.10
