From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next] 8139cp: remove a won't occurred BUG_ON
Date: Sun, 26 Jan 2014 16:33:38 +0800
Message-ID: <52E4C862.9050103@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:45900 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348AbaAZIdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jan 2014 03:33:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when variable i go to the BUG_ON the value is equal to the CP_NUM_STATS,
so the BUG_ON won't occur, so remove it

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 drivers/net/ethernet/realtek/8139cp.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 737c1a8..b70e184 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -1585,7 +1585,6 @@ static void cp_get_ethtool_stats (struct net_device *dev,
 	tmp_stats[i++] = le16_to_cpu(nic_stats->tx_abort);
 	tmp_stats[i++] = le16_to_cpu(nic_stats->tx_underrun);
 	tmp_stats[i++] = cp->cp_stats.rx_frags;
-	BUG_ON(i != CP_NUM_STATS);
 
 	dma_free_coherent(&cp->pdev->dev, sizeof(*nic_stats), nic_stats, dma);
 }
-- 
1.7.12
