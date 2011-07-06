From: David Miller <davem@davemloft.net>
Subject: [PATCH] veth: Kill unused code label and code block.
Date: Tue, 05 Jul 2011 23:49:30 -0700 (PDT)
Message-ID: <20110705.234930.2282002049899864045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35175 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930Ab1GFGtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 02:49:31 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p666nUeA017060
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 5 Jul 2011 23:49:30 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/veth.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 9eb92bf..19e0b0c 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -148,13 +148,6 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	return NETDEV_TX_OK;
 
-tx_drop:
-	kfree_skb(skb);
-	u64_stats_update_begin(&stats->syncp);
-	stats->tx_dropped++;
-	u64_stats_update_end(&stats->syncp);
-	return NETDEV_TX_OK;
-
 rx_drop:
 	u64_stats_update_begin(&rcv_stats->syncp);
 	rcv_stats->rx_dropped++;
-- 
1.7.6

