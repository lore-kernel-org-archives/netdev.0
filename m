From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH net-next 1/2] cpmac: remove unused variable.
Date: Sun, 31 May 2009 22:57:07 +0200
Message-ID: <200905312257.09467.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:35939 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbZEaU5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2009 16:57:13 -0400
Received: by ewy24 with SMTP id 24so7430598ewy.37
        for <netdev@vger.kernel.org>; Sun, 31 May 2009 13:57:14 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the unused variables in
cpmac_hw_error, cpmac_tx_timeout and cpmac_probe.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index cfb4198..08e2f67 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -731,7 +731,6 @@ static void cpmac_clear_tx(struct net_device *dev)
 
 static void cpmac_hw_error(struct work_struct *work)
 {
-	int i;
 	struct cpmac_priv *priv =
 		container_of(work, struct cpmac_priv, reset_work);
 
@@ -818,7 +817,6 @@ static irqreturn_t cpmac_irq(int irq, void *dev_id)
 
 static void cpmac_tx_timeout(struct net_device *dev)
 {
-	int i;
 	struct cpmac_priv *priv = netdev_priv(dev);
 
 	spin_lock(&priv->lock);
@@ -1110,7 +1108,7 @@ static int external_switch;
 
 static int __devinit cpmac_probe(struct platform_device *pdev)
 {
-	int rc, phy_id, i;
+	int rc, phy_id;
 	char *mdio_bus_id = "0";
 	struct resource *mem;
 	struct cpmac_priv *priv;
