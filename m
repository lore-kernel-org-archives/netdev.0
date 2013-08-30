From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH v2 01/11] net: calxedaxgmac: remove NETIF_F_FRAGLIST setting
Date: Thu, 29 Aug 2013 22:13:38 -0500
Message-ID: <1377832428-18117-1-git-send-email-robherring2@gmail.com>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	bhutchings@solarflare.com, Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:46524 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753340Ab3H3DN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:13:59 -0400
Received: by mail-ob0-f181.google.com with SMTP id dn14so1390227obc.12
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 20:13:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>

The xgmac does not actually handle frag lists, so this option should not
be set. It does not appear to have had any impact though.

Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
v2: No change

 drivers/net/ethernet/calxeda/xgmac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 7cb148c..71f6720 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1759,7 +1759,7 @@ static int xgmac_probe(struct platform_device *pdev)
 	if (device_can_wakeup(priv->device))
 		priv->wolopts = WAKE_MAGIC;	/* Magic Frame as default */
 
-	ndev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA;
+	ndev->hw_features = NETIF_F_SG | NETIF_F_HIGHDMA;
 	if (readl(priv->base + XGMAC_DMA_HW_FEATURE) & DMA_HW_FEAT_TXCOESEL)
 		ndev->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 				     NETIF_F_RXCSUM;
-- 
1.8.1.2
