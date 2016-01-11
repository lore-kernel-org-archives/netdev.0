From: Marek Vasut <marex@denx.de>
Subject: [PATCH 4/5] net: can: ifi: Add DT bindings for ifi,canfd
Date: Mon, 11 Jan 2016 19:48:02 +0100
Message-ID: <1452538083-7331-4-git-send-email-marex@denx.de>
References: <1452538083-7331-1-git-send-email-marex@denx.de>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Marek Vasut <marex@denx.de>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:46020 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933969AbcAKSsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 13:48:19 -0500
In-Reply-To: <1452538083-7331-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add device tree bindings for the I/F/I CANFD controller IP core.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>
Cc: Wolfgang Grandegger <wg@grandegger.com>
---
 Documentation/devicetree/bindings/net/can/ifi_canfd.txt | 15 +++++++++++++++
 1 file changed, 15 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/can/ifi_canfd.txt

diff --git a/Documentation/devicetree/bindings/net/can/ifi_canfd.txt b/Documentation/devicetree/bindings/net/can/ifi_canfd.txt
new file mode 100644
index 0000000..20ea5c7
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/can/ifi_canfd.txt
@@ -0,0 +1,15 @@
+IFI CANFD controller
+--------------------
+
+Required properties:
+  - compatible: Should be "ifi,canfd-1.0"
+  - reg: Should contain CAN controller registers location and length
+  - interrupts: Should contain IRQ line for the CAN controller
+
+Example:
+
+	canfd0: canfd@ff220000 {
+		compatible = "ifi,canfd-1.0";
+		reg = <0xff220000 0x00001000>;
+		interrupts = <0 43 0>;
+	};
-- 
2.1.4
