From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 3/6] qlge: Reduce print level in data path statements.
Date: Mon,  5 Jul 2010 15:19:39 -0700
Message-ID: <1278368382-23887-4-git-send-email-ron.mercer@qlogic.com>
References: <1278368382-23887-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:42713 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755012Ab0GEXFS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jul 2010 19:05:18 -0400
In-Reply-To: <1278368382-23887-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index e99c2c6..e39451b 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1521,7 +1521,7 @@ static void ql_process_mac_rx_page(struct ql_adapter *qdev,
 
 	/* Frame error, so drop the packet. */
 	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
-		netif_err(qdev, drv, qdev->ndev,
+		netif_info(qdev, drv, qdev->ndev,
 			  "Receive error, flags2 = 0x%x\n", ib_mac_rsp->flags2);
 		rx_ring->rx_errors++;
 		goto err_out;
@@ -1618,7 +1618,7 @@ static void ql_process_mac_rx_skb(struct ql_adapter *qdev,
 
 	/* Frame error, so drop the packet. */
 	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
-		netif_err(qdev, drv, qdev->ndev,
+		netif_info(qdev, drv, qdev->ndev,
 			  "Receive error, flags2 = 0x%x\n", ib_mac_rsp->flags2);
 		dev_kfree_skb_any(skb);
 		rx_ring->rx_errors++;
@@ -1939,7 +1939,7 @@ static void ql_process_mac_split_rx_intr(struct ql_adapter *qdev,
 
 	/* Frame error, so drop the packet. */
 	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
-		netif_err(qdev, drv, qdev->ndev,
+		netif_info(qdev, drv, qdev->ndev,
 			  "Receive error, flags2 = 0x%x\n", ib_mac_rsp->flags2);
 		dev_kfree_skb_any(skb);
 		rx_ring->rx_errors++;
-- 
1.6.0.2

