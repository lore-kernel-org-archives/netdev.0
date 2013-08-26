From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH 09/11] net: calxedaxgmac: remove some unused statistic counters
Date: Mon, 26 Aug 2013 17:45:24 -0500
Message-ID: <1377557126-10716-9-git-send-email-robherring2@gmail.com>
References: <1377557126-10716-1-git-send-email-robherring2@gmail.com>
Cc: Andreas Herrmann <andreas.herrmann@calxeda.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377557126-10716-1-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

rx_sa_filter_fail and tx_undeflow events are unused and impossible
to occur based on how the h/w is used. We never filter on source MAC
address and TX store and forward mode prevents underflow events.

Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 9b6eff5..b206268 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -353,11 +353,9 @@ struct xgmac_extra_stats {
 	/* Receive errors */
 	unsigned long rx_watchdog;
 	unsigned long rx_da_filter_fail;
-	unsigned long rx_sa_filter_fail;
 	unsigned long rx_payload_error;
 	unsigned long rx_ip_header_error;
 	/* Tx/Rx IRQ errors */
-	unsigned long tx_undeflow;
 	unsigned long tx_process_stopped;
 	unsigned long rx_buf_unav;
 	unsigned long rx_process_stopped;
@@ -1584,7 +1582,6 @@ static const struct xgmac_stats xgmac_gstrings_stats[] = {
 	XGMAC_STAT(rx_payload_error),
 	XGMAC_STAT(rx_ip_header_error),
 	XGMAC_STAT(rx_da_filter_fail),
-	XGMAC_STAT(rx_sa_filter_fail),
 	XGMAC_STAT(fatal_bus_error),
 	XGMAC_HW_STAT(rx_watchdog, XGMAC_MMC_RXWATCHDOG),
 	XGMAC_HW_STAT(tx_vlan, XGMAC_MMC_TXVLANFRAME),
-- 
1.8.1.2
