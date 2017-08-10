From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: [PATCH v4 3/4] dt-bindings: can: m_can: Document new can transceiver binding
Date: Wed, 9 Aug 2017 19:59:15 -0500
Message-ID: <20170810005916.27163-4-fcooper@ti.com>
References: <20170810005916.27163-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper@ti.com>
To: <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>,
        <dev.kurt@vandijck-laurijssen.be>, <andrew@lunn.ch>,
        <sergei.shtylyov@cogentembedded.com>, <socketcan@hartkopp.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170810005916.27163-1-fcooper@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add information regarding can-transceiver binding. This is especially
important for MCAN since the IP allows CAN FD mode to run significantly
faster than what most transceivers are capable of.

Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
---
Drop unit address.
Switch from using fixed-transceiver to can-transceiver
Indicate that can-transceiver is an optional subnode not a property.

 Documentation/devicetree/bindings/net/can/m_can.txt | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/can/m_can.txt b/Documentation/devicetree/bindings/net/can/m_can.txt
index 9e33177..ee90aac 100644
--- a/Documentation/devicetree/bindings/net/can/m_can.txt
+++ b/Documentation/devicetree/bindings/net/can/m_can.txt
@@ -43,6 +43,11 @@ Required properties:
 			  Please refer to 2.4.1 Message RAM Configuration in
 			  Bosch M_CAN user manual for details.
 
+Optional Subnode:
+- can-transceiver	: Can-transceiver subnode describing maximum speed
+			  that can be used for CAN/CAN-FD modes. See
+			  Documentation/devicetree/bindings/net/can/can-transceiver.txt
+			  for details.
 Example:
 SoC dtsi:
 m_can1: can@020e8000 {
@@ -64,4 +69,8 @@ Board dts:
 	pinctrl-names = "default";
 	pinctrl-0 = <&pinctrl_m_can1>;
 	status = "enabled";
+
+	can-transceiver@ {
+		max-bitrate = <5000000>;
+	};
 };
-- 
2.9.4.dirty
