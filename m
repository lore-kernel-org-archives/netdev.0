From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH 12/13] ARM: dts: am4372: Add control module syscon node
Date: Mon, 8 Sep 2014 17:10:41 +0300
Message-ID: <1410185442-907-13-git-send-email-rogerq@ti.com>
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

Use syscon regmap to expose the Control module register space.
This register space is shared between many users e.g. DCAN, USB, display, etc.

Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 arch/arm/boot/dts/am4372.dtsi | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/arm/boot/dts/am4372.dtsi b/arch/arm/boot/dts/am4372.dtsi
index a705e50..d38a0ed 100644
--- a/arch/arm/boot/dts/am4372.dtsi
+++ b/arch/arm/boot/dts/am4372.dtsi
@@ -59,6 +59,11 @@
 		cache-level = <2>;
 	};
 
+	am43xx_control_module: control_module@4a002000 {
+		compatible = "syscon";
+		reg = <0x44e10000 0x7f4>;
+	};
+
 	am43xx_pinmux: pinmux@44e10800 {
 		compatible = "pinctrl-single";
 		reg = <0x44e10800 0x31c>;
-- 
1.8.3.2

