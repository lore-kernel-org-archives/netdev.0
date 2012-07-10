From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH 3/4] net: calxedaxgmac: set outstanding AXI bus transactions to 8
Date: Mon,  9 Jul 2012 19:16:09 -0500
Message-ID: <1341879370-23385-4-git-send-email-robherring2@gmail.com>
References: <1341879370-23385-1-git-send-email-robherring2@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:33188 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755277Ab2GJAQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 20:16:25 -0400
In-Reply-To: <1341879370-23385-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>

Increase the number of outstanding read and write AXI transactions from 1
to 8 for better performance.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 3ca1d79..abb8f40 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -970,7 +970,7 @@ static int xgmac_hw_init(struct net_device *dev)
 	writel(DMA_INTR_DEFAULT_MASK, ioaddr + XGMAC_DMA_INTR_ENA);
 
 	/* XGMAC requires AXI bus init. This is a 'magic number' for now */
-	writel(0x000100E, ioaddr + XGMAC_DMA_AXI_BUS);
+	writel(0x0077000E, ioaddr + XGMAC_DMA_AXI_BUS);
 
 	ctrl |= XGMAC_CONTROL_DDIC | XGMAC_CONTROL_JE | XGMAC_CONTROL_ACS |
 		XGMAC_CONTROL_CAR;
-- 
1.7.9.5
