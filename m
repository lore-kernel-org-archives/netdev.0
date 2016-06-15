From: Vincent Palatin <vpalatin@chromium.org>
Subject: [PATCH v2 3/3] ARM: dts: rockchip: add interrupt for Wake-on-Lan on RK3288
Date: Wed, 15 Jun 2016 11:32:23 -0700
Message-ID: <6a7df421fce9603d31757b80bd96c72598c7fc2f.1466015458.git.vpalatin@chromium.org>
References: <CAP_ceTxFuCsqRQJ_9GMc5PSKqczA8Qwaa0jX22wQ2Dq=+GZUuQ@mail.gmail.com>
 <cover.1466015458.git.vpalatin@chromium.org>
Cc: linux-kernel@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
	Douglas Anderson <dianders@chromium.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	=?UTF-8?q?Heiko=20St=C3=BCbner?= <heiko@sntech.de>,
	Shunqian Zheng <zhengsq@rock-chips.com>,
	Vincent Palatin <vpalatin@chromium.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1466015458.git.vpalatin@chromium.org>
In-Reply-To: <cover.1466015458.git.vpalatin@chromium.org>
References: <cover.1466015458.git.vpalatin@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to use Wake-on-Lan on RK3288 integrated MAC, we need to wake-up
the CPU on the PMT interrupt when the MAC and the PHY are in low power mode.
Adding the interrupt declaration.

Signed-off-by: Vincent Palatin <vpalatin@chromium.org>
---
 arch/arm/boot/dts/rk3288.dtsi | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/rk3288.dtsi b/arch/arm/boot/dts/rk3288.dtsi
index 3b44ef3..3ebee53 100644
--- a/arch/arm/boot/dts/rk3288.dtsi
+++ b/arch/arm/boot/dts/rk3288.dtsi
@@ -539,8 +539,9 @@
 	gmac: ethernet@ff290000 {
 		compatible = "rockchip,rk3288-gmac";
 		reg = <0xff290000 0x10000>;
-		interrupts = <GIC_SPI 27 IRQ_TYPE_LEVEL_HIGH>;
-		interrupt-names = "macirq";
+		interrupts = <GIC_SPI 27 IRQ_TYPE_LEVEL_HIGH>,
+				<GIC_SPI 28 IRQ_TYPE_LEVEL_HIGH>;
+		interrupt-names = "macirq", "eth_wake_irq";
 		rockchip,grf = <&grf>;
 		clocks = <&cru SCLK_MAC>,
 			<&cru SCLK_MAC_RX>, <&cru SCLK_MAC_TX>,
-- 
2.8.0.rc3.226.g39d4020
