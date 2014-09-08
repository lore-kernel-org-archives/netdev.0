From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH 13/13] ARM: dts: am4372: Add dcan raminit bits
Date: Mon, 8 Sep 2014 17:10:42 +0300
Message-ID: <1410185442-907-14-git-send-email-rogerq@ti.com>
References: <1410185442-907-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tglx@linutronix.de>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>, Roger Quadros <rogerq@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>, <tony@atomide.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1410185442-907-1-git-send-email-rogerq@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add RAMINIT specific bits into the DCAN nodes.

Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 arch/arm/boot/dts/am4372.dtsi | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/am4372.dtsi b/arch/arm/boot/dts/am4372.dtsi
index d38a0ed..33d27cd 100644
--- a/arch/arm/boot/dts/am4372.dtsi
+++ b/arch/arm/boot/dts/am4372.dtsi
@@ -899,7 +899,10 @@
 			clocks = <&dcan0_fck>;
 			clock-names = "fck";
 			reg = <0x481cc000 0x2000
-				0x44e10644 0x4>;
+				0x644 0x4>; /* index to RAMINIT reg within syscon */
+			raminit-syscon = <&am43xx_control_module>;
+			raminit-start-bit = <0>;
+			raminit-done-bit = <8>;
 			interrupts = <GIC_SPI 52 IRQ_TYPE_LEVEL_HIGH>;
 			status = "disabled";
 		};
@@ -910,7 +913,10 @@
 			clocks = <&dcan1_fck>;
 			clock-names = "fck";
 			reg = <0x481d0000 0x2000
-				0x44e10644 0x4>;
+				0x644 0x4>; /* index to RAMINIT reg within syscon */
+			raminit-syscon = <&am43xx_control_module>;
+			raminit-start-bit = <1>;
+			raminit-done-bit = <9>;
 			interrupts = <GIC_SPI 49 IRQ_TYPE_LEVEL_HIGH>;
 			status = "disabled";
 		};
-- 
1.8.3.2

