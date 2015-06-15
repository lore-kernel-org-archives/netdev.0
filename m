From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH] net: stmmac: dwmac-rk: Don't add function name in info or err messages
Date: Mon, 15 Jun 2015 17:44:19 +0000
Message-ID: <1434390259-27145-1-git-send-email-romain.perier@gmail.com>
Cc: netdev@vger.kernel.org, linux-rockchip@lists.infradead.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:36673 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752139AbbFORoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 13:44:22 -0400
Received: by wgzl5 with SMTP id l5so49891951wgz.3
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 10:44:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These kind of informations are only useful for debugging and should not be
displayed in normal modules message.

Signed-off-by: Romain Perier <romain.perier@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 75 +++++++++++++-------------
 1 file changed, 36 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 30e28f0..26c339d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -98,7 +98,7 @@ static void set_to_rgmii(struct rk_priv_data *bsp_priv,
 	struct device *dev = &bsp_priv->pdev->dev;
 
 	if (IS_ERR(bsp_priv->grf)) {
-		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		dev_err(dev, "Missing rockchip,grf property\n");
 		return;
 	}
 
@@ -115,7 +115,7 @@ static void set_to_rmii(struct rk_priv_data *bsp_priv)
 	struct device *dev = &bsp_priv->pdev->dev;
 
 	if (IS_ERR(bsp_priv->grf)) {
-		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		dev_err(dev, "Missing rockchip,grf property\n");
 		return;
 	}
 
@@ -128,7 +128,7 @@ static void set_rgmii_speed(struct rk_priv_data *bsp_priv, int speed)
 	struct device *dev = &bsp_priv->pdev->dev;
 
 	if (IS_ERR(bsp_priv->grf)) {
-		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		dev_err(dev, "Missing rockchip,grf property\n");
 		return;
 	}
 
@@ -147,7 +147,7 @@ static void set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
 	struct device *dev = &bsp_priv->pdev->dev;
 
 	if (IS_ERR(bsp_priv->grf)) {
-		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		dev_err(dev, "Missing rockchip,grf property\n");
 		return;
 	}
 
@@ -170,46 +170,46 @@ static int gmac_clk_init(struct rk_priv_data *bsp_priv)
 
 	bsp_priv->mac_clk_rx = devm_clk_get(dev, "mac_clk_rx");
 	if (IS_ERR(bsp_priv->mac_clk_rx))
-		dev_err(dev, "%s: cannot get clock %s\n",
-			__func__, "mac_clk_rx");
+		dev_err(dev, "cannot get clock %s\n",
+			"mac_clk_rx");
 
 	bsp_priv->mac_clk_tx = devm_clk_get(dev, "mac_clk_tx");
 	if (IS_ERR(bsp_priv->mac_clk_tx))
-		dev_err(dev, "%s: cannot get clock %s\n",
-			__func__, "mac_clk_tx");
+		dev_err(dev, "cannot get clock %s\n",
+			"mac_clk_tx");
 
 	bsp_priv->aclk_mac = devm_clk_get(dev, "aclk_mac");
 	if (IS_ERR(bsp_priv->aclk_mac))
-		dev_err(dev, "%s: cannot get clock %s\n",
-			__func__, "aclk_mac");
+		dev_err(dev, "cannot get clock %s\n",
+			"aclk_mac");
 
 	bsp_priv->pclk_mac = devm_clk_get(dev, "pclk_mac");
 	if (IS_ERR(bsp_priv->pclk_mac))
-		dev_err(dev, "%s: cannot get clock %s\n",
-			__func__, "pclk_mac");
+		dev_err(dev, "cannot get clock %s\n",
+			"pclk_mac");
 
 	bsp_priv->clk_mac = devm_clk_get(dev, "stmmaceth");
 	if (IS_ERR(bsp_priv->clk_mac))
-		dev_err(dev, "%s: cannot get clock %s\n",
-			__func__, "stmmaceth");
+		dev_err(dev, "cannot get clock %s\n",
+			"stmmaceth");
 
 	if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RMII) {
 		bsp_priv->clk_mac_ref = devm_clk_get(dev, "clk_mac_ref");
 		if (IS_ERR(bsp_priv->clk_mac_ref))
-			dev_err(dev, "%s: cannot get clock %s\n",
-				__func__, "clk_mac_ref");
+			dev_err(dev, "cannot get clock %s\n",
+				"clk_mac_ref");
 
 		if (!bsp_priv->clock_input) {
 			bsp_priv->clk_mac_refout =
 				devm_clk_get(dev, "clk_mac_refout");
 			if (IS_ERR(bsp_priv->clk_mac_refout))
-				dev_err(dev, "%s: cannot get clock %s\n",
-					__func__, "clk_mac_refout");
+				dev_err(dev, "cannot get clock %s\n",
+					"clk_mac_refout");
 		}
 	}
 
 	if (bsp_priv->clock_input) {
-		dev_info(dev, "%s: clock input from PHY\n", __func__);
+		dev_info(dev, "clock input from PHY\n");
 	} else {
 		if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RMII)
 			clk_set_rate(bsp_priv->clk_mac_pll, 50000000);
@@ -296,20 +296,18 @@ static int phy_power_on(struct rk_priv_data *bsp_priv, bool enable)
 	struct device *dev = &bsp_priv->pdev->dev;
 
 	if (!ldo) {
-		dev_err(dev, "%s: no regulator found\n", __func__);
+		dev_err(dev, "no regulator found\n");
 		return -1;
 	}
 
 	if (enable) {
 		ret = regulator_enable(ldo);
 		if (ret)
-			dev_err(dev, "%s: fail to enable phy-supply\n",
-				__func__);
+			dev_err(dev, "fail to enable phy-supply\n");
 	} else {
 		ret = regulator_disable(ldo);
 		if (ret)
-			dev_err(dev, "%s: fail to disable phy-supply\n",
-				__func__);
+			dev_err(dev, "fail to disable phy-supply\n");
 	}
 
 	return 0;
@@ -341,12 +339,11 @@ static void *rk_gmac_setup(struct platform_device *pdev)
 
 	ret = of_property_read_string(dev->of_node, "clock_in_out", &strings);
 	if (ret) {
-		dev_err(dev, "%s: Can not read property: clock_in_out.\n",
-			__func__);
+		dev_err(dev, "Can not read property: clock_in_out.\n");
 		bsp_priv->clock_input = true;
 	} else {
-		dev_info(dev, "%s: clock input or output? (%s).\n",
-			 __func__, strings);
+		dev_info(dev, "clock input or output? (%s).\n",
+			 strings);
 		if (!strcmp(strings, "input"))
 			bsp_priv->clock_input = true;
 		else
@@ -356,22 +353,22 @@ static void *rk_gmac_setup(struct platform_device *pdev)
 	ret = of_property_read_u32(dev->of_node, "tx_delay", &value);
 	if (ret) {
 		bsp_priv->tx_delay = 0x30;
-		dev_err(dev, "%s: Can not read property: tx_delay.", __func__);
-		dev_err(dev, "%s: set tx_delay to 0x%x\n",
-			__func__, bsp_priv->tx_delay);
+		dev_err(dev, "Can not read property: tx_delay.");
+		dev_err(dev, "set tx_delay to 0x%x\n",
+			bsp_priv->tx_delay);
 	} else {
-		dev_info(dev, "%s: TX delay(0x%x).\n", __func__, value);
+		dev_info(dev, "TX delay(0x%x).\n", value);
 		bsp_priv->tx_delay = value;
 	}
 
 	ret = of_property_read_u32(dev->of_node, "rx_delay", &value);
 	if (ret) {
 		bsp_priv->rx_delay = 0x10;
-		dev_err(dev, "%s: Can not read property: rx_delay.", __func__);
-		dev_err(dev, "%s: set rx_delay to 0x%x\n",
-			__func__, bsp_priv->rx_delay);
+		dev_err(dev, "Can not read property: rx_delay.");
+		dev_err(dev, "set rx_delay to 0x%x\n",
+			bsp_priv->rx_delay);
 	} else {
-		dev_info(dev, "%s: RX delay(0x%x).\n", __func__, value);
+		dev_info(dev, "RX delay(0x%x).\n", value);
 		bsp_priv->rx_delay = value;
 	}
 
@@ -381,13 +378,13 @@ static void *rk_gmac_setup(struct platform_device *pdev)
 
 	/*rmii or rgmii*/
 	if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RGMII) {
-		dev_info(dev, "%s: init for RGMII\n", __func__);
+		dev_info(dev, "init for RGMII\n");
 		set_to_rgmii(bsp_priv, bsp_priv->tx_delay, bsp_priv->rx_delay);
 	} else if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RMII) {
-		dev_info(dev, "%s: init for RMII\n", __func__);
+		dev_info(dev, "init for RMII\n");
 		set_to_rmii(bsp_priv);
 	} else {
-		dev_err(dev, "%s: NO interface defined!\n", __func__);
+		dev_err(dev, "NO interface defined!\n");
 	}
 
 	gmac_clk_init(bsp_priv);
-- 
1.9.1
