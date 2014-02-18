From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH] Documentation: broadcom-bcmgenet: fix address and cells properties
Date: Mon, 17 Feb 2014 16:27:35 -0800
Message-ID: <1392683255-28136-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <sergei.shtylyov@cogentembedded.com>,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:34590 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869AbaBRA16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 19:27:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a typo in the Device Tree binding for the
leading '#'.

Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
index 88c3d04..25339ee 100644
--- a/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
+++ b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
@@ -10,8 +10,8 @@ Required properties:
 - phy-mode: String, operation mode of the PHY interface. Supported values are
   "mii", "rgmii", "rgmii-txid", "rev-mii", "moca". Analogous to ePAPR
   "phy-connection-type" values
-- address-cells: should be 1
-- size-cells: should be 1
+- #address-cells: should be 1
+- #size-cells: should be 1
 
 Optional properties:
 - clocks: When provided, must be two phandles to the functional clocks nodes
@@ -42,8 +42,8 @@ MDIO bus node required properties:
   parent node compatible property (e.g: brcm,genet-v4 pairs with
   brcm,genet-mdio-v4)
 - reg: address and length relative to the parent node base register address
-- address-cells: address cell for MDIO bus addressing, should be 1
-- size-cells: size of the cells for MDIO bus addressing, should be 0
+- #address-cells: address cell for MDIO bus addressing, should be 1
+- #size-cells: size of the cells for MDIO bus addressing, should be 0
 
 Ethernet PHY node properties:
 
-- 
1.8.3.2
