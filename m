From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v5 10/11] dt-bindings: orion-mdio: document the new xmdio compatible
Date: Thu, 15 Jun 2017 16:43:25 +0200
Message-ID: <20170615144326.24463-11-antoine.tenart@free-electrons.com>
References: <20170615144326.24463-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:34826 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752650AbdFOOoF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 10:44:05 -0400
In-Reply-To: <20170615144326.24463-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A new compatible for Marvell xMDIO interfaces was added into the Marvell
MDIO driver. Document this new compatible.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 Documentation/devicetree/bindings/net/marvell-orion-mdio.txt | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
index ccdabdcc8618..42cd81090a2c 100644
--- a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
+++ b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
@@ -1,12 +1,14 @@
 * Marvell MDIO Ethernet Controller interface
 
 The Ethernet controllers of the Marvel Kirkwood, Dove, Orion5x,
-MV78xx0, Armada 370 and Armada XP have an identical unit that provides
-an interface with the MDIO bus. This driver handles this MDIO
-interface.
+MV78xx0, Armada 370, Armada XP, Armada 7k and Armada 8k have an
+identical unit that provides an interface with the MDIO bus.
+Additionally, Armada 7k and Armada 8k has a second unit which
+provides an interface with the xMDIO bus. This driver handles
+these interfaces.
 
 Required properties:
-- compatible: "marvell,orion-mdio"
+- compatible: "marvell,orion-mdio" or "marvell,xmdio"
 - reg: address and length of the MDIO registers.  When an interrupt is
   not present, the length is the size of the SMI register (4 bytes)
   otherwise it must be 0x84 bytes to cover the interrupt control
-- 
2.9.4
