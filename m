From: David Wu <david.wu@rock-chips.com>
Subject: [PATCH 08/11] ARM: dts: rk322x: Add support internal phy for gmac
Date: Fri, 23 Jun 2017 13:02:05 +0800
Message-ID: <1498194125-8186-1-git-send-email-david.wu@rock-chips.com>
References: <1498192929-7519-1-git-send-email-david.wu@rock-chips.com>
Cc: andrew@lunn.ch, f.fainelli@gmail.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, huangtao@rock-chips.com,
        hwg@rock-chips.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Wu <david.wu@rock-chips.com>
To: davem@davemloft.net, heiko@sntech.de, robh+dt@kernel.org,
        mark.rutland@arm.com, catalin.marinas@arm.com, will.deacon@arm.com,
        olof@lixom.net, linux@armlinux.org.uk, arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498192929-7519-1-git-send-email-david.wu@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds internal mac phy clock and internal mac phy reset
for rk gmac using.

Signed-off-by: David Wu <david.wu@rock-chips.com>
---
 arch/arm/boot/dts/rk322x.dtsi | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/arm/boot/dts/rk322x.dtsi b/arch/arm/boot/dts/rk322x.dtsi
index 48a0c1c..203a583 100644
--- a/arch/arm/boot/dts/rk322x.dtsi
+++ b/arch/arm/boot/dts/rk322x.dtsi
@@ -427,13 +427,13 @@
 		clocks = <&cru SCLK_MAC>, <&cru SCLK_MAC_RX>,
 			<&cru SCLK_MAC_TX>, <&cru SCLK_MAC_REF>,
 			<&cru SCLK_MAC_REFOUT>, <&cru ACLK_GMAC>,
-			<&cru PCLK_GMAC>;
+			<&cru PCLK_GMAC>, <&cru SCLK_MAC_PHY>;
 		clock-names = "stmmaceth", "mac_clk_rx",
 			"mac_clk_tx", "clk_mac_ref",
 			"clk_mac_refout", "aclk_mac",
-			"pclk_mac";
-		resets = <&cru SRST_GMAC>;
-		reset-names = "stmmaceth";
+			"pclk_mac", "clk_macphy";
+		resets = <&cru SRST_GMAC>, <&cru SRST_MACPHY>;
+		reset-names = "stmmaceth", "mac-phy";
 		rockchip,grf = <&grf>;
 		status = "disabled";
 	};
-- 
1.9.1
