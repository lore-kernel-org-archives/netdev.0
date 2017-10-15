From: Roman Yeryomin <roman@advem.lv>
Subject: [PATCH net-next 05/10] net: korina: remove unused korina_private members
Date: Sun, 15 Oct 2017 19:23:29 +0300
Message-ID: <20171015162329.925-1-roman@advem.lv>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1l1v.rtu.lv ([213.175.92.62]:52620 "EHLO mail.pbx.lv"
        rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
        id S1751848AbdJOQ2L (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Oct 2017 12:28:11 -0400
Received: from ubrain.corp.ubnt.com (unknown [213.175.92.61])
        by mail.pbx.lv (MailSystem) with ESMTPSA id BF5BE1918A2
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 19:22:50 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 64ae32af7539..59d4554c43c9 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -118,9 +118,6 @@ struct korina_private {
 	struct sk_buff *rx_skb[KORINA_NUM_RDS];
 
 	int rx_next_done;
-	int rx_chain_head;
-	int rx_chain_tail;
-	enum chain_status rx_chain_status;
 
 	int tx_next_done;
 	int tx_chain_head;
@@ -135,7 +132,6 @@ struct korina_private {
 	spinlock_t lock;	/* NIC xmit lock */
 
 	int dma_halt_cnt;
-	int dma_run_cnt;
 	struct napi_struct napi;
 	struct timer_list media_check_timer;
 	struct mii_if_info mii_if;
@@ -770,9 +766,6 @@ static int korina_alloc_ring(struct net_device *dev)
 	lp->rd_ring[i - 1].control |= DMA_DESC_COD;
 
 	lp->rx_next_done  = 0;
-	lp->rx_chain_head = 0;
-	lp->rx_chain_tail = 0;
-	lp->rx_chain_status = desc_empty;
 
 	return 0;
 }
-- 
2.11.0
