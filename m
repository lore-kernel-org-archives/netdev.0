From: Jie Deng <Jie.Deng1@synopsys.com>
Subject: [PATCH net-next 1/2] net: phy: add extension of phy-mode for XLGMII
Date: Wed, 7 Dec 2016 11:57:38 +0800
Message-ID: <6d4a65c5488364cdaec72eb22e742aa7e94dfebb.1481075763.git.jiedeng@synopsys.com>
References: <cover.1481075763.git.jiedeng@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <CARLOS.PALMINHA@synopsys.com>,
        <lars.persson@axis.com>, <thomas.lendacky@amd.com>,
        Jie Deng <Jie.Deng1@synopsys.com>
To: <davem@davemloft.net>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1481075763.git.jiedeng@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds phy-mode support for Synopsys XLGMAC

Signed-off-by: Jie Deng <jiedeng@synopsys.com>
---
 Documentation/devicetree/bindings/net/ethernet.txt | 1 +
 include/linux/phy.h                                | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/ethernet.txt b/Documentation/devicetree/bindings/net/ethernet.txt
index 0515095..2378f00 100644
--- a/Documentation/devicetree/bindings/net/ethernet.txt
+++ b/Documentation/devicetree/bindings/net/ethernet.txt
@@ -28,6 +28,7 @@ The following properties are common to the Ethernet controllers:
   * "rtbi"
   * "smii"
   * "xgmii"
+  * "xlgmii"
   * "trgmii"
 - phy-connection-type: the same as "phy-mode" property but described in ePAPR;
 - phy-handle: phandle, specifies a reference to a node representing a PHY
diff --git a/include/linux/phy.h b/include/linux/phy.h
index feb8a98..b52f9f8 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -79,6 +79,7 @@
 	PHY_INTERFACE_MODE_RTBI,
 	PHY_INTERFACE_MODE_SMII,
 	PHY_INTERFACE_MODE_XGMII,
+	PHY_INTERFACE_MODE_XLGMII,
 	PHY_INTERFACE_MODE_MOCA,
 	PHY_INTERFACE_MODE_QSGMII,
 	PHY_INTERFACE_MODE_TRGMII,
@@ -136,6 +137,8 @@ static inline const char *phy_modes(phy_interface_t interface)
 		return "smii";
 	case PHY_INTERFACE_MODE_XGMII:
 		return "xgmii";
+	case PHY_INTERFACE_MODE_XLGMII:
+		return "xlgmii";
 	case PHY_INTERFACE_MODE_MOCA:
 		return "moca";
 	case PHY_INTERFACE_MODE_QSGMII:
-- 
1.9.1
