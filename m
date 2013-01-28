From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: [PATCH v2 2/6] ARM: davinci: da850: add DT node for mdio device
Date: Mon, 28 Jan 2013 19:17:55 +0530
Message-ID: <1359380879-26306-3-git-send-email-prabhakar.lad@ti.com>
References: <1359380879-26306-1-git-send-email-prabhakar.lad@ti.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, Heiko Schocher <hs@denx.de>,
	"Lad, Prabhakar" <prabhakar.lad@ti.com>
To: Sekhar Nori <nsekhar@ti.com>, linux-arm-kernel@lists.infradead.org,
	davinci-linux-open-source@linux.davincidsp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1359380879-26306-1-git-send-email-prabhakar.lad@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lad, Prabhakar <prabhakar.lad@ti.com>

Add mdio device tree node information to da850 by
providing register details and bus frequency of mdio.

Signed-off-by: Lad, Prabhakar <prabhakar.lad@ti.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: davinci-linux-open-source@linux.davincidsp.com
Cc: netdev@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
Cc: Sekhar Nori <nsekhar@ti.com>
Cc: Heiko Schocher <hs@denx.de>
---
 arch/arm/boot/dts/da850-evm.dts |    3 +++
 arch/arm/boot/dts/da850.dtsi    |    7 +++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/arch/arm/boot/dts/da850-evm.dts b/arch/arm/boot/dts/da850-evm.dts
index 98c1a48..a319491 100644
--- a/arch/arm/boot/dts/da850-evm.dts
+++ b/arch/arm/boot/dts/da850-evm.dts
@@ -27,6 +27,9 @@
 		serial2: serial@1d0d000 {
 			status = "okay";
 		};
+		mdio: davinci_mdio@1e24000 {
+			status = "okay";
+		};
 	};
 	nand_cs3@62000000 {
 		status = "okay";
diff --git a/arch/arm/boot/dts/da850.dtsi b/arch/arm/boot/dts/da850.dtsi
index 7c84822..ba28f2d 100644
--- a/arch/arm/boot/dts/da850.dtsi
+++ b/arch/arm/boot/dts/da850.dtsi
@@ -81,6 +81,13 @@
 			interrupts = <61>;
 			status = "disabled";
 		};
+		mdio: davinci_mdio@1e24000 {
+			compatible = "ti,davinci_mdio";
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0x224000 0x1000>;
+			bus_freq = <2200000>;
+		};
 	};
 	nand_cs3@62000000 {
 		compatible = "ti,davinci-nand";
-- 
1.7.4.1
