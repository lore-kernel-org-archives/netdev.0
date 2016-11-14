From: Akshay Bhat <akshay.bhat@timesys.com>
Subject: [PATCH 1/2] can: holt_hi311x: document device tree bindings
Date: Mon, 14 Nov 2016 12:55:43 -0500
Message-ID: <1479146144-29143-1-git-send-email-akshay.bhat@timesys.com>
Cc: mark.rutland@arm.com, linux-can@vger.kernel.org,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Akshay Bhat <akshay.bhat@timesys.com>,
        Akshay Bhat <nodeax@gmail.com>
To: wg@grandegger.com, mkl@pengutronix.de, robh+dt@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Document the HOLT HI-311x CAN device tree bindings.

Signed-off-by: Akshay Bhat <nodeax@gmail.com>
---
 .../devicetree/bindings/net/can/holt_hi311x.txt    | 24 ++++++++++++++++++++++
 1 file changed, 24 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/can/holt_hi311x.txt

diff --git a/Documentation/devicetree/bindings/net/can/holt_hi311x.txt b/Documentation/devicetree/bindings/net/can/holt_hi311x.txt
new file mode 100644
index 0000000..23aa94e
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/can/holt_hi311x.txt
@@ -0,0 +1,24 @@
+* Holt HI-311X stand-alone CAN controller device tree bindings
+
+Required properties:
+ - compatible: Should be one of the following:
+   - "holt,hi3110" for HI-3110
+ - reg: SPI chip select.
+ - clocks: The clock feeding the CAN controller.
+ - interrupt-parent: The parent interrupt controller.
+ - interrupts: Should contain IRQ line for the CAN controller.
+
+Optional properties:
+ - vdd-supply: Regulator that powers the CAN controller.
+ - xceiver-supply: Regulator that powers the CAN transceiver.
+
+Example:
+	can0: can@1 {
+		compatible = "holt,hi3110";
+		reg = <1>;
+		clocks = <&clk32m>;
+		interrupt-parent = <&gpio4>;
+		interrupts = <13 IRQ_TYPE_EDGE_RISING>;
+		vdd-supply = <&reg5v0>;
+		xceiver-supply = <&reg5v0>;
+	};
-- 
2.8.1
