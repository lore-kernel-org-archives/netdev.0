From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH v3 09/11] net: calxedaxgmac: remove some unused statistic counters
Date: Fri, 30 Aug 2013 16:49:27 -0500
Message-ID: <1377899369-23252-9-git-send-email-robherring2@gmail.com>
References: <1377899369-23252-1-git-send-email-robherring2@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:46938 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756107Ab3H3VuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 17:50:07 -0400
Received: by mail-ob0-f179.google.com with SMTP id fb19so2389938obc.38
        for <netdev@vger.kernel.org>; Fri, 30 Aug 2013 14:50:07 -0700 (PDT)
In-Reply-To: <1377899369-23252-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
index 0cff9e3..04c585c 100644
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
@@ -1581,7 +1579,6 @@ static const struct xgmac_stats xgmac_gstrings_stats[] = {
 	XGMAC_STAT(rx_payload_error),
 	XGMAC_STAT(rx_ip_header_error),
 	XGMAC_STAT(rx_da_filter_fail),
-	XGMAC_STAT(rx_sa_filter_fail),
 	XGMAC_STAT(fatal_bus_error),
 	XGMAC_HW_STAT(rx_watchdog, XGMAC_MMC_RXWATCHDOG),
 	XGMAC_HW_STAT(tx_vlan, XGMAC_MMC_TXVLANFRAME),
-- 
1.8.1.2
