From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH v2 09/11] net: calxedaxgmac: remove some unused statistic counters
Date: Thu, 29 Aug 2013 22:13:46 -0500
Message-ID: <1377832428-18117-9-git-send-email-robherring2@gmail.com>
References: <1377832428-18117-1-git-send-email-robherring2@gmail.com>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	bhutchings@solarflare.com, Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:34053 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754307Ab3H3DOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:14:08 -0400
Received: by mail-oa0-f44.google.com with SMTP id l17so1679966oag.3
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 20:14:08 -0700 (PDT)
In-Reply-To: <1377832428-18117-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>

rx_sa_filter_fail and tx_undeflow events are unused and impossible
to occur based on how the h/w is used. We never filter on source MAC
address and TX store and forward mode prevents underflow events.

Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
v2: No change

 drivers/net/ethernet/calxeda/xgmac.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index a7cb18d..4ecf937 100644
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
