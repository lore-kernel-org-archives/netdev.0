From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH v6 2/3] can: sja1000: add documentation for Technologic Systems version
Date: Wed, 20 Jan 2016 16:43:30 +0100
Message-ID: <1453304611-31207-3-git-send-email-mkl@pengutronix.de>
References: <1453304611-31207-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org,
	Damien Riegel <damien.riegel@savoirfairelinux.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1453304611-31207-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Damien Riegel <damien.riegel@savoirfairelinux.com>

This commit adds documentation for the Technologic Systems version of
SJA1000. The difference with the NXP version is in the way the registers
are accessed.

Signed-off-by: Damien Riegel <damien.riegel@savoirfairelinux.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 Documentation/devicetree/bindings/net/can/sja1000.txt | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/can/sja1000.txt b/Documentation/devicetree/bindings/net/can/sja1000.txt
index b4a6d53fb01a..ac3160eca96a 100644
--- a/Documentation/devicetree/bindings/net/can/sja1000.txt
+++ b/Documentation/devicetree/bindings/net/can/sja1000.txt
@@ -2,7 +2,7 @@ Memory mapped SJA1000 CAN controller from NXP (formerly Philips)
 
 Required properties:
 
-- compatible : should be "nxp,sja1000".
+- compatible : should be one of "nxp,sja1000", "technologic,sja1000".
 
 - reg : should specify the chip select, address offset and size required
 	to map the registers of the SJA1000. The size is usually 0x80.
@@ -14,6 +14,7 @@ Optional properties:
 
 - reg-io-width : Specify the size (in bytes) of the IO accesses that
 	should be performed on the device.  Valid value is 1, 2 or 4.
+	This property is ignored for technologic version.
 	Default to 1 (8 bits).
 
 - nxp,external-clock-frequency : Frequency of the external oscillator
-- 
2.7.0.rc3

