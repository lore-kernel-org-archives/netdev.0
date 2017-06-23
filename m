From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 2/4] net: phy: Support "internal" PHY interface
Date: Fri, 23 Jun 2017 10:31:33 -0700
Message-ID: <20170623173135.22912-3-f.fainelli@gmail.com>
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

Now that the Device Tree binding has been updated, update the PHY
library phy_interface_t and phy_modes to support the "internal" PHY
interface type.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/phy.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 23d2e46dd322..1d8d70193782 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -64,6 +64,7 @@
 /* Interface Mode definitions */
 typedef enum {
 	PHY_INTERFACE_MODE_NA,
+	PHY_INTERFACE_MODE_INTERNAL,
 	PHY_INTERFACE_MODE_MII,
 	PHY_INTERFACE_MODE_GMII,
 	PHY_INTERFACE_MODE_SGMII,
@@ -114,6 +115,8 @@ static inline const char *phy_modes(phy_interface_t interface)
 	switch (interface) {
 	case PHY_INTERFACE_MODE_NA:
 		return "";
+	case PHY_INTERFACE_MODE_INTERNAL:
+		return "internal";
 	case PHY_INTERFACE_MODE_MII:
 		return "mii";
 	case PHY_INTERFACE_MODE_GMII:
-- 
2.9.3
