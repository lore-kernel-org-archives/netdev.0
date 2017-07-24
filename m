From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: [PATCH v2 3/4] can: m_can: Update documentation to mention new fixed transceiver binding
Date: Mon, 24 Jul 2017 18:05:20 -0500
Message-ID: <20170724230521.1436-4-fcooper@ti.com>
References: <20170724230521.1436-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper@ti.com>
To: <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>,
        <dev.kurt@vandijck-laurijssen.be>, <andrew@lunn.ch>,
        <sergei.shtylyov@cogentembedded.com>, <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx194.ext.ti.com ([198.47.27.80]:49159 "EHLO
        lelnx194.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932996AbdGXXGL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 19:06:11 -0400
In-Reply-To: <20170724230521.1436-1-fcooper@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add information regarding fixed transceiver binding. This is especially
important for MCAN since the IP allows CAN FD mode to run significantly
faster than what most transceivers are capable of.

Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
---
Version 2 changes:
Drop unit address

 Documentation/devicetree/bindings/net/can/m_can.txt | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/can/m_can.txt b/Documentation/devicetree/bindings/net/can/m_can.txt
index 9e33177..e4abd2c 100644
--- a/Documentation/devicetree/bindings/net/can/m_can.txt
+++ b/Documentation/devicetree/bindings/net/can/m_can.txt
@@ -43,6 +43,11 @@ Required properties:
 			  Please refer to 2.4.1 Message RAM Configuration in
 			  Bosch M_CAN user manual for details.
 
+Optional properties:
+- fixed-transceiver	: Fixed-transceiver subnode describing maximum speed
+			  that can be used for CAN and/or CAN-FD modes.  See
+			  Documentation/devicetree/bindings/net/can/fixed-transceiver.txt
+			  for details.
 Example:
 SoC dtsi:
 m_can1: can@020e8000 {
@@ -64,4 +69,9 @@ Board dts:
 	pinctrl-names = "default";
 	pinctrl-0 = <&pinctrl_m_can1>;
 	status = "enabled";
+
+	fixed-transceiver {
+		max-arbitration-speed = <1000000>;
+		max-data-speed = <5000000>;
+	};
 };
-- 
2.10.0
