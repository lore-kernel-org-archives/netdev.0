From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2] Documentation: broadcom-bcmgenet: fix address and cells properties
Date: Tue, 18 Feb 2014 14:36:15 -0800
Message-ID: <1392762975-19132-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <sergei.shtylyov@cogentembedded.com>,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:46327 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768AbaBRWgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 17:36:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a typo in the Device Tree binding for the
leading '#'.

Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- rebased on top of net-next/master 

 Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
index 88fb958..f2febb9 100644
--- a/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
+++ b/Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
@@ -8,8 +8,8 @@ Required properties:
   interrupt line, while the second cell is the interrupt for the ring
   RX and TX queues operating in ring mode
 - phy-mode: see ethernet.txt file in the same directory
-- address-cells: should be 1
-- size-cells: should be 1
+- #address-cells: should be 1
+- #size-cells: should be 1
 
 Optional properties:
 - clocks: When provided, must be two phandles to the functional clocks nodes
@@ -39,8 +39,8 @@ MDIO bus node required properties:
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
