From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: [PATCH 6/6] net/macb: enable scatter-gather feature and set DMA burst length for sama5d4 gem
Date: Fri, 18 Jul 2014 16:32:48 +0200
Message-ID: <69a7e4f82584ee4d0222565873460837655a9eb7.1405689937.git.cyrille.pitchen@atmel.com>
References: <cover.1405689937.git.cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<soren.brinkmann@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:40116 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762177AbaGROcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2014 10:32:51 -0400
In-Reply-To: <cover.1405689937.git.cyrille.pitchen@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 6acd6e2..08105dc 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2002,6 +2002,11 @@ static struct macb_config sama5d3_config = {
 	.dma_burst_length = 16,
 };
 
+static struct macb_config sama5d4_config = {
+	.caps = 0,
+	.dma_burst_length = 4,
+};
+
 static const struct of_device_id macb_dt_ids[] = {
 	{ .compatible = "cdns,at32ap7000-macb" },
 	{ .compatible = "cdns,at91sam9260-macb" },
@@ -2009,6 +2014,7 @@ static const struct of_device_id macb_dt_ids[] = {
 	{ .compatible = "cdns,pc302-gem", .data = &pc302gem_config },
 	{ .compatible = "cdns,gem", .data = &pc302gem_config },
 	{ .compatible = "atmel,sama5d3-gem", .data = &sama5d3_config },
+	{ .compatible = "atmel,sama5d4-gem", .data = &sama5d4_config },
 	{ /* sentinel */ }
 };
 MODULE_DEVICE_TABLE(of, macb_dt_ids);
-- 
1.8.2.2
