From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v3 4/9] amd-xgbe: Clarify output message about
 queues
Date: Fri, 20 Mar 2015 11:50:10 -0500
Message-ID: <20150320165010.13799.37023.stgit@tlendack-t1.amdoffice.net>
References: <20150320164936.13799.13796.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0128.outbound.protection.outlook.com ([207.46.100.128]:31328
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751969AbbCTQuP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 12:50:15 -0400
In-Reply-To: <20150320164936.13799.13796.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clarify that the queues referred to in a message when the device is
brought up are hardware queues and not necessarily related to the
Linux network queues.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 400757b..29137c9 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -2004,7 +2004,8 @@ static void xgbe_config_tx_fifo_size(struct xgbe_prv_data *pdata)
 	for (i = 0; i < pdata->tx_q_count; i++)
 		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, TQS, fifo_size);
 
-	netdev_notice(pdata->netdev, "%d Tx queues, %d byte fifo per queue\n",
+	netdev_notice(pdata->netdev,
+		      "%d Tx hardware queues, %d byte fifo per queue\n",
 		      pdata->tx_q_count, ((fifo_size + 1) * 256));
 }
 
@@ -2019,7 +2020,8 @@ static void xgbe_config_rx_fifo_size(struct xgbe_prv_data *pdata)
 	for (i = 0; i < pdata->rx_q_count; i++)
 		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, RQS, fifo_size);
 
-	netdev_notice(pdata->netdev, "%d Rx queues, %d byte fifo per queue\n",
+	netdev_notice(pdata->netdev,
+		      "%d Rx hardware queues, %d byte fifo per queue\n",
 		      pdata->rx_q_count, ((fifo_size + 1) * 256));
 }
 
