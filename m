From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 1/4] dt-bindings: Add "internal" as a valid 'phy-mode' property
Date: Fri, 23 Jun 2017 10:31:32 -0700
Message-ID: <20170623173135.22912-2-f.fainelli@gmail.com>
References: <20170623173135.22912-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Russell King <rmk+kernel@armlinux.org.uk>,
        netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
        devicetree@vger.kernel.org (open list:OPEN FIRMWARE AND FLATTENED
        DEVICE TREE BINDINGS), linux-kernel@vger.kernel.org (open list),
        david.wu@rock-chips.com, opendmb@gmail.com
To: netdev@ver.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170623173135.22912-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A number of Ethernet MACs have internal Ethernet PHYs and the internal
wiring makes it so that this knowledge needs to be available using the
standard 'phy-mode' property.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/devicetree/bindings/net/ethernet.txt | 1 +
 1 file changed, 1 insertion(+)

diff --git a/Documentation/devicetree/bindings/net/ethernet.txt b/Documentation/devicetree/bindings/net/ethernet.txt
index d4abe9a98109..edd7fd2bbbf9 100644
--- a/Documentation/devicetree/bindings/net/ethernet.txt
+++ b/Documentation/devicetree/bindings/net/ethernet.txt
@@ -11,6 +11,7 @@ The following properties are common to the Ethernet controllers:
   the maximum frame size (there's contradiction in ePAPR).
 - phy-mode: string, operation mode of the PHY interface. This is now a de-facto
   standard property; supported values are:
+  * "internal"
   * "mii"
   * "gmii"
   * "sgmii"
-- 
2.9.3
