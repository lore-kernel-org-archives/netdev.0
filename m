From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 1/2] ethernet: sun4i: Drop the older compatibles
Date: Fri,  7 Feb 2014 21:57:51 +0100
Message-ID: <1391806672-27846-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:49810 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751689AbaBGVAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 16:00:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DT maintainers said it was OK to remove the older compatible pattern, since
we are still a moving target, users will have to update their DT either way.

Drop the older ethernet compatibles, to avoid maintaining legacy compatibles.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt | 3 +--
 drivers/net/ethernet/allwinner/sun4i-emac.c                    | 3 ---
 2 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt b/Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt
index 863d5b81..82f1571 100644
--- a/Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt
+++ b/Documentation/devicetree/bindings/net/allwinner,sun4i-emac.txt
@@ -1,8 +1,7 @@
 * Allwinner EMAC ethernet controller
 
 Required properties:
-- compatible: should be "allwinner,sun4i-a10-emac" (Deprecated:
-              "allwinner,sun4i-emac")
+- compatible: should be "allwinner,sun4i-a10-emac"
 - reg: address and length of the register set for the device.
 - interrupts: interrupt for the device
 - phy: A phandle to a phy node defining the PHY address (as the reg
diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index 6673106..04a9699 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -931,9 +931,6 @@ static int emac_resume(struct platform_device *dev)
 
 static const struct of_device_id emac_of_match[] = {
 	{.compatible = "allwinner,sun4i-a10-emac",},
-
-	/* Deprecated */
-	{.compatible = "allwinner,sun4i-emac",},
 	{},
 };
 
-- 
1.8.4.2
