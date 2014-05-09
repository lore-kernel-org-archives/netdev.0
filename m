From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v2 1/3] drivers: net: cpsw-phy-sel: initialize priv->dev
Date: Fri, 9 May 2014 19:07:33 +0530
Message-ID: <1399642655-6412-2-git-send-email-mugunthanvnm@ti.com>
References: <1399642655-6412-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:42867 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756541AbaEINhm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 May 2014 09:37:42 -0400
In-Reply-To: <1399642655-6412-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

priv->dev is uninitialized, initializing with pdev->dev

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw-phy-sel.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ti/cpsw-phy-sel.c b/drivers/net/ethernet/ti/cpsw-phy-sel.c
index 148da9a..86b5dce 100644
--- a/drivers/net/ethernet/ti/cpsw-phy-sel.c
+++ b/drivers/net/ethernet/ti/cpsw-phy-sel.c
@@ -132,6 +132,7 @@ static int cpsw_phy_sel_probe(struct platform_device *pdev)
 		return -ENOMEM;
 	}
 
+	priv->dev = &pdev->dev;
 	priv->cpsw_phy_sel = of_id->data;
 
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "gmii-sel");
-- 
1.9.2.459.g68773ac
