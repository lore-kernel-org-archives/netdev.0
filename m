From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 2/2] mdio: sun4i: Drop the older compatibles
Date: Fri,  7 Feb 2014 21:57:52 +0100
Message-ID: <1391806672-27846-2-git-send-email-maxime.ripard@free-electrons.com>
References: <1391806672-27846-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:49809 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751529AbaBGVAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 16:00:43 -0500
In-Reply-To: <1391806672-27846-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DT maintainers said it was OK to remove the older compatible pattern, since
we are still a moving target, users will have to update their DT either way.

Drop the older mdio compatibles, to avoid maintaining legacy compatibles.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 Documentation/devicetree/bindings/net/allwinner,sun4i-mdio.txt | 1 -
 drivers/net/phy/mdio-sun4i.c                                   | 3 ---
 2 files changed, 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/allwinner,sun4i-mdio.txt b/Documentation/devicetree/bindings/net/allwinner,sun4i-mdio.txt
index 4ec5641..dc49966 100644
--- a/Documentation/devicetree/bindings/net/allwinner,sun4i-mdio.txt
+++ b/Documentation/devicetree/bindings/net/allwinner,sun4i-mdio.txt
@@ -2,7 +2,6 @@
 
 Required properties:
 - compatible: should be "allwinner,sun4i-a10-mdio"
-              (Deprecated: "allwinner,sun4i-mdio").
 - reg: address and length of the register set for the device.
 
 Optional properties:
diff --git a/drivers/net/phy/mdio-sun4i.c b/drivers/net/phy/mdio-sun4i.c
index 7f4a66d..56806ae 100644
--- a/drivers/net/phy/mdio-sun4i.c
+++ b/drivers/net/phy/mdio-sun4i.c
@@ -172,9 +172,6 @@ static int sun4i_mdio_remove(struct platform_device *pdev)
 
 static const struct of_device_id sun4i_mdio_dt_ids[] = {
 	{ .compatible = "allwinner,sun4i-a10-mdio" },
-
-	/* Deprecated */
-	{ .compatible = "allwinner,sun4i-mdio" },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, sun4i_mdio_dt_ids);
-- 
1.8.4.2
