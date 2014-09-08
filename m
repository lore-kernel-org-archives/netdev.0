From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH 10/13] arm: dts: am437x-gp: Add dcan support
Date: Mon, 8 Sep 2014 17:10:39 +0300
Message-ID: <1410185442-907-11-git-send-email-rogerq@ti.com>
References: <1410185442-907-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tglx@linutronix.de>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>, <tony@atomide.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1410185442-907-1-git-send-email-rogerq@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mugunthan V N <mugunthanvnm@ti.com>

Add DCAN support for AM437x GP EVM with both DCAN instances.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
Signed-off-by: George Cherian <george.cherian@ti.com>
Signed-off-by: Sekhar Nori <nsekhar@ti.com>
---
 arch/arm/boot/dts/am437x-gp-evm.dts | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/arch/arm/boot/dts/am437x-gp-evm.dts b/arch/arm/boot/dts/am437x-gp-evm.dts
index e7ac47f..6d03baa 100644
--- a/arch/arm/boot/dts/am437x-gp-evm.dts
+++ b/arch/arm/boot/dts/am437x-gp-evm.dts
@@ -254,6 +254,20 @@
 			0x238 (PIN_OUTPUT_PULLUP | MUX_MODE7)
 		>;
 	};
+
+	dcan0_default: dcan0_default_pins {
+		pinctrl-single,pins = <
+			0x178 (PIN_OUTPUT_PULLDOWN | MUX_MODE2) /* uart1_ctsn.d_can0_tx */
+			0x17c (PIN_INPUT_PULLUP | MUX_MODE2) /* uart1_rtsn.d_can0_rx */
+		>;
+	};
+
+	dcan1_default: dcan1_default_pins {
+		pinctrl-single,pins = <
+			0x180 (PIN_OUTPUT_PULLDOWN | MUX_MODE2) /* uart1_rxd.d_can1_tx */
+			0x184 (PIN_INPUT_PULLUP | MUX_MODE2) /* uart1_txd.d_can1_rx */
+		>;
+	};
 };
 
 &i2c0 {
@@ -511,3 +525,15 @@
 		};
 	};
 };
+
+&dcan0 {
+	pinctrl-names = "default";
+	pinctrl-0 = <&dcan0_default>;
+	status = "okay";
+};
+
+&dcan1 {
+	pinctrl-names = "default";
+	pinctrl-0 = <&dcan1_default>;
+	status = "okay";
+};
-- 
1.8.3.2

