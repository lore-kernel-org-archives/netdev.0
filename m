From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 2/2] drivers: net: cpsw-phy-sel: add am43xx platform support
Date: Fri, 9 May 2014 16:33:24 +0530
Message-ID: <1399633404-5818-3-git-send-email-mugunthanvnm@ti.com>
References: <1399633404-5818-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:47020 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754085AbaEILDf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 May 2014 07:03:35 -0400
In-Reply-To: <1399633404-5818-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

AM43xx phy mode selection is similar to AM33xx platform, so adding only
the compatibility string to the driver

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 Documentation/devicetree/bindings/net/cpsw-phy-sel.txt | 1 +
 drivers/net/ethernet/ti/cpsw-phy-sel.c                 | 4 ++++
 2 files changed, 5 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/cpsw-phy-sel.txt b/Documentation/devicetree/bindings/net/cpsw-phy-sel.txt
index d9da911..764c0c7 100644
--- a/Documentation/devicetree/bindings/net/cpsw-phy-sel.txt
+++ b/Documentation/devicetree/bindings/net/cpsw-phy-sel.txt
@@ -4,6 +4,7 @@ TI CPSW Phy mode Selection Device Tree Bindings
 Required properties:
 - compatible		: Should be "ti,am3352-cpsw-phy-sel" for am335x platform and
 			  "ti,dra7xx-cpsw-phy-sel" for dra7xx platform
+			  "ti,am43xx-cpsw-phy-sel" for am43xx platform
 - reg			: physical base address and size of the cpsw
 			  registers map
 - reg-names		: names of the register map given in "reg" node
diff --git a/drivers/net/ethernet/ti/cpsw-phy-sel.c b/drivers/net/ethernet/ti/cpsw-phy-sel.c
index b93838d..aa8bf45 100644
--- a/drivers/net/ethernet/ti/cpsw-phy-sel.c
+++ b/drivers/net/ethernet/ti/cpsw-phy-sel.c
@@ -167,6 +167,10 @@ static const struct of_device_id cpsw_phy_sel_id_table[] = {
 		.compatible	= "ti,dra7xx-cpsw-phy-sel",
 		.data		= &cpsw_gmii_sel_dra7xx,
 	},
+	{
+		.compatible	= "ti,am43xx-cpsw-phy-sel",
+		.data		= &cpsw_gmii_sel_am3352,
+	},
 	{}
 };
 MODULE_DEVICE_TABLE(of, cpsw_phy_sel_id_table);
-- 
1.9.2.459.g68773ac
