From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] Doc: Micrel-ksz90x1.txt: Document deprecated MAC OF properties
Date: Wed,  9 Dec 2015 19:39:03 +0100
Message-ID: <1449686343-14925-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34233 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753087AbbLISjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2015 13:39:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phy properties are expected to be found in the PHY OF node. However
this Micrel driver also allows them to be placed into the MAC OF node.
This is deprecated. Document it as such, and remove the example using
the deprecated method to prevent people copying it into new device
tree files.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 .../devicetree/bindings/net/micrel-ksz90x1.txt          | 17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/micrel-ksz90x1.txt b/Documentation/devicetree/bindings/net/micrel-ksz90x1.txt
index 692076fda0e5..f9c32adab5c6 100644
--- a/Documentation/devicetree/bindings/net/micrel-ksz90x1.txt
+++ b/Documentation/devicetree/bindings/net/micrel-ksz90x1.txt
@@ -1,8 +1,9 @@
 Micrel KSZ9021/KSZ9031 Gigabit Ethernet PHY
 
-Some boards require special tuning values, particularly when it comes to
-clock delays. You can specify clock delay values by adding
-micrel-specific properties to an Ethernet OF device node.
+Some boards require special tuning values, particularly when it comes
+to clock delays. You can specify clock delay values in the PHY OF
+device node. Deprecated, but still supported, these properties can
+also be added to an Ethernet OF device node.
 
 Note that these settings are applied after any phy-specific fixup from
 phy_fixup_list (see phy_init_hw() from drivers/net/phy/phy_device.c),
@@ -57,16 +58,6 @@ KSZ9031:
 
 Examples:
 
-	/* Attach to an Ethernet device with autodetected PHY */
-	&enet {
-		rxc-skew-ps = <3000>;
-		rxdv-skew-ps = <0>;
-		txc-skew-ps = <3000>;
-		txen-skew-ps = <0>;
-		status = "okay";
-	};
-
-	/* Attach to an explicitly-specified PHY */
 	mdio {
 		phy0: ethernet-phy@0 {
 			rxc-skew-ps = <3000>;
-- 
2.6.2
