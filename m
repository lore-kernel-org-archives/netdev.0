From: Jie Deng <Jie.Deng1@synopsys.com>
Subject: [PATCH net-next] net: phy: add extension of phy-mode for XLGMII
Date: Wed, 4 Jan 2017 13:04:04 +0800
Message-ID: <b5378ab79043fe46027756546c17e0a54df4a9f0.1483505550.git.jiedeng@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Jie Deng <Jie.Deng1@synopsys.com>
To: <f.fainelli@gmail.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Synopsys DWC_xlgmac core provides a multiplexed 40-Gigabit
Media-Independent Interface (XLGMII, an IEEE 802.3 Clause 81
compliant reconciliation sub-layer) for communication with
the 100/50/40/25-Gigabit PHY and 10-Gigabit Media-Independent
Interface (XGMII, an IEEE 802.3 Clause 46 compliant reconciliation
sub-layer) for communication with the 10-Gigabit PHY.

Currently, There are only interface mode definitions for "xgmii".
This patch adds the definitions for the PHY layer to recognize
"xlgmii" as a valid PHY interface.

Signed-off-by: Jie Deng <jiedeng@synopsys.com>
---
 include/linux/phy.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index f7d95f6..7b6bfb3 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -82,6 +82,7 @@
 	PHY_INTERFACE_MODE_MOCA,
 	PHY_INTERFACE_MODE_QSGMII,
 	PHY_INTERFACE_MODE_TRGMII,
+	PHY_INTERFACE_MODE_XLGMII,
 	PHY_INTERFACE_MODE_MAX,
 } phy_interface_t;
 
@@ -142,6 +143,8 @@ static inline const char *phy_modes(phy_interface_t interface)
 		return "qsgmii";
 	case PHY_INTERFACE_MODE_TRGMII:
 		return "trgmii";
+	case PHY_INTERFACE_MODE_XLGMII:
+		return "xlgmii";
 	default:
 		return "unknown";
 	}
-- 
1.9.1
