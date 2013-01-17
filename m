From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net-next] cxgb3: Fix Tx csum stats
Date: Thu, 17 Jan 2013 14:59:59 +0530
Message-ID: <1358414999-20242-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	abhishek@chelsio.com, Vipul Pandya <vipul@chelsio.com>,
	Jay Hernandez <jay@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31821 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755282Ab3AQJfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 04:35:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jay Hernandez <jay@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb3/sge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
index dd901c5..9096dc0 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -1278,7 +1278,7 @@ netdev_tx_t t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* update port statistics */
-	if (skb->ip_summed == CHECKSUM_COMPLETE)
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		qs->port_stats[SGE_PSTAT_TX_CSUM]++;
 	if (skb_shinfo(skb)->gso_size)
 		qs->port_stats[SGE_PSTAT_TSO]++;
-- 
1.7.1
