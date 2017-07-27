From: David Wu <david.wu@rock-chips.com>
Subject: [PATCH v2 08/11] ARM: dts: rk322x: Add support internal phy for gmac
Date: Thu, 27 Jul 2017 21:02:19 +0800
Message-ID: <1501160540-30662-4-git-send-email-david.wu@rock-chips.com>
References: <1501160156-30328-1-git-send-email-david.wu@rock-chips.com>
 <1501160540-30662-1-git-send-email-david.wu@rock-chips.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Wu <david.wu@rock-chips.com>
To: davem@davemloft.net, heiko@sntech.de, andrew@lunn.ch,
        f.fainelli@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com, olof@lixom.net,
        linux@armlinux.org.uk, arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501160540-30662-1-git-send-email-david.wu@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds internal mac phy clock and internal mac phy reset
for rk gmac using.

Signed-off-by: David Wu <david.wu@rock-chips.com>
---
 arch/arm/boot/dts/rk322x.dtsi | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/arm/boot/dts/rk322x.dtsi b/arch/arm/boot/dts/rk322x.dtsi
index f3e4ffd..3778f7d 100644
--- a/arch/arm/boot/dts/rk322x.dtsi
+++ b/arch/arm/boot/dts/rk322x.dtsi
@@ -611,13 +611,13 @@
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
