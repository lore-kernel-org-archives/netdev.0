From: Jan Luebbe <jlu@pengutronix.de>
Subject: [PATCH 1/3] net: cpsw: replace pr_xxx with dev_xxx functions
Date: Mon,  3 Dec 2012 14:49:27 +0100
Message-ID: <1354542569-6165-1-git-send-email-jlu@pengutronix.de>
Cc: "David S. Miller" <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Vaibhav Hiremath <hvaibhav@ti.com>,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	Jan Luebbe <jlu@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jan Luebbe <jlu@pengutronix.de>
---
 drivers/net/ethernet/ti/cpsw.c |   47 ++++++++++++++++++++--------------------
 1 file changed, 23 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index fb1a692..c0e676a 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -729,7 +729,7 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		return -EINVAL;
 
 	if (of_property_read_u32(node, "slaves", &prop)) {
-		pr_err("Missing slaves property in the DT.\n");
+		dev_err(&pdev->dev, "Missing slaves property in the DT.\n");
 		return -EINVAL;
 	}
 	data->slaves = prop;
@@ -737,91 +737,91 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	data->slave_data = kzalloc(sizeof(struct cpsw_slave_data) *
 				   data->slaves, GFP_KERNEL);
 	if (!data->slave_data) {
-		pr_err("Could not allocate slave memory.\n");
+		dev_err(&pdev->dev, "Could not allocate slave memory.\n");
 		return -EINVAL;
 	}
 
 	data->no_bd_ram = of_property_read_bool(node, "no_bd_ram");
 
 	if (of_property_read_u32(node, "cpdma_channels", &prop)) {
-		pr_err("Missing cpdma_channels property in the DT.\n");
+		dev_err(&pdev->dev, "Missing cpdma_channels property in the DT.\n");
 		ret = -EINVAL;
 		goto error_ret;
 	}
 	data->channels = prop;
 
 	if (of_property_read_u32(node, "host_port_no", &prop)) {
-		pr_err("Missing host_port_no property in the DT.\n");
+		dev_err(&pdev->dev, "Missing host_port_no property in the DT.\n");
 		ret = -EINVAL;
 		goto error_ret;
 	}
 	data->host_port_num = prop;
 
 	if (of_property_read_u32(node, "cpdma_reg_ofs", &prop)) {
-		pr_err("Missing cpdma_reg_ofs property in the DT.\n");
+		dev_err(&pdev->dev, "Missing cpdma_reg_ofs property in the DT.\n");
 		ret = -EINVAL;
 		goto error_ret;
 	}
 	data->cpdma_reg_ofs = prop;
 
 	if (of_property_read_u32(node, "cpdma_sram_ofs", &prop)) {
-		pr_err("Missing cpdma_sram_ofs property in the DT.\n");
+		dev_err(&pdev->dev, "Missing cpdma_sram_ofs property in the DT.\n");
 		ret = -EINVAL;
 		goto error_ret;
 	}
 	data->cpdma_sram_ofs = prop;
 
 	if (of_property_read_u32(node, "ale_reg_ofs", &prop)) {
-		pr_err("Missing ale_reg_ofs property in the DT.\n");
+		dev_err(&pdev->dev, "Missing ale_reg_ofs property in the DT.\n");
 		ret = -EINVAL;
 		goto error_ret;
 	}
 	data->ale_reg_ofs = prop;
 
 	if (of_property_read_u32(node, "ale_entries", &prop)) {
-		pr_err("Missing ale_entries property in the DT.\n");
+		dev_err(&pdev->dev, "Missing ale_entries property in the DT.\n");
 		ret = -EINVAL;
 		goto error_ret;
 	}
 	data->ale_entries = prop;
 
 	if (of_property_read_u32(node, "host_port_reg_ofs", &prop)) {
-		pr_err("Missing host_port_reg_ofs property in the DT.\n");
+		dev_err(&pdev->dev, "Missing host_port_reg_ofs property in the DT.\n");
 		ret = -EINVAL;
 		goto error_ret;
 	}
 	data->host_port_reg_ofs = prop;
 
 	if (of_property_read_u32(node, "hw_stats_reg_ofs", &prop)) {
-		pr_err("Missing hw_stats_reg_ofs property in the DT.\n");
+		dev_err(&pdev->dev, "Missing hw_stats_reg_ofs property in the DT.\n");
 		ret = -EINVAL;
 		goto error_ret;
 	}
 	data->hw_stats_reg_ofs = prop;
 
 	if (of_property_read_u32(node, "bd_ram_ofs", &prop)) {
-		pr_err("Missing bd_ram_ofs property in the DT.\n");
+		dev_err(&pdev->dev, "Missing bd_ram_ofs property in the DT.\n");
 		ret = -EINVAL;
 		goto error_ret;
 	}
 	data->bd_ram_ofs = prop;
 
 	if (of_property_read_u32(node, "bd_ram_size", &prop)) {
-		pr_err("Missing bd_ram_size property in the DT.\n");
+		dev_err(&pdev->dev, "Missing bd_ram_size property in the DT.\n");
 		ret = -EINVAL;
 		goto error_ret;
 	}
 	data->bd_ram_size = prop;
 
 	if (of_property_read_u32(node, "rx_descs", &prop)) {
-		pr_err("Missing rx_descs property in the DT.\n");
+		dev_err(&pdev->dev, "Missing rx_descs property in the DT.\n");
 		ret = -EINVAL;
 		goto error_ret;
 	}
 	data->rx_descs = prop;
 
 	if (of_property_read_u32(node, "mac_control", &prop)) {
-		pr_err("Missing mac_control property in the DT.\n");
+		dev_err(&pdev->dev, "Missing mac_control property in the DT.\n");
 		ret = -EINVAL;
 		goto error_ret;
 	}
@@ -833,14 +833,14 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		const void *mac_addr = NULL;
 
 		if (of_property_read_string(slave_node, "phy_id", &phy_id)) {
-			pr_err("Missing slave[%d] phy_id property\n", i);
+			dev_err(&pdev->dev, "Missing slave[%d] phy_id property.\n", i);
 			ret = -EINVAL;
 			goto error_ret;
 		}
 		slave_data->phy_id = phy_id;
 
 		if (of_property_read_u32(slave_node, "slave_reg_ofs", &prop)) {
-			pr_err("Missing slave[%d] slave_reg_ofs property\n", i);
+			dev_err(&pdev->dev, "Missing slave[%d] slave_reg_ofs property.\n", i);
 			ret = -EINVAL;
 			goto error_ret;
 		}
@@ -848,8 +848,7 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 
 		if (of_property_read_u32(slave_node, "sliver_reg_ofs",
 					 &prop)) {
-			pr_err("Missing slave[%d] sliver_reg_ofs property\n",
-				i);
+			dev_err(&pdev->dev, "Missing slave[%d] sliver_reg_ofs property.\n", i);
 			ret = -EINVAL;
 			goto error_ret;
 		}
@@ -868,7 +867,7 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	ret = of_platform_populate(node, NULL, NULL, &pdev->dev);
 	/* We do not want to force this, as in some cases may not have child */
 	if (ret)
-		pr_warn("Doesn't have any child node\n");
+		dev_warn(&pdev->dev, "Doesn't have any child node\n");
 
 	return 0;
 
@@ -890,7 +889,7 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 
 	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
 	if (!ndev) {
-		pr_err("error allocating net_device\n");
+		pr_err("cpsw: error allocating net_device\n");
 		return -ENOMEM;
 	}
 
@@ -909,7 +908,7 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 	pm_runtime_enable(&pdev->dev);
 
 	if (cpsw_probe_dt(&priv->data, pdev)) {
-		pr_err("cpsw: platform data missing\n");
+		dev_err(&pdev->dev, "platform data missing\n");
 		ret = -ENODEV;
 		goto clean_ndev_ret;
 	}
@@ -917,10 +916,10 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 
 	if (is_valid_ether_addr(data->slave_data[0].mac_addr)) {
 		memcpy(priv->mac_addr, data->slave_data[0].mac_addr, ETH_ALEN);
-		pr_info("Detected MACID = %pM", priv->mac_addr);
+		dev_info(&pdev->dev, "Detected MACID = %pM", priv->mac_addr);
 	} else {
 		eth_random_addr(priv->mac_addr);
-		pr_info("Random MACID = %pM", priv->mac_addr);
+		dev_info(&pdev->dev, "Random MACID = %pM", priv->mac_addr);
 	}
 
 	memcpy(ndev->dev_addr, priv->mac_addr, ETH_ALEN);
@@ -1120,7 +1119,7 @@ static int __devexit cpsw_remove(struct platform_device *pdev)
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct cpsw_priv *priv = netdev_priv(ndev);
 
-	pr_info("removing device");
+	dev_info(&pdev->dev, "removing device");
 	platform_set_drvdata(pdev, NULL);
 
 	free_irq(ndev->irq, priv);
-- 
1.7.10.4

