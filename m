From: Damien Riegel <damien.riegel@savoirfairelinux.com>
Subject: [PATCH 1/2] can: sja1000: add documentation for Technologic Systems version
Date: Fri, 18 Dec 2015 15:17:24 -0500
Message-ID: <1450469845-12900-1-git-send-email-damien.riegel@savoirfairelinux.com>
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	kernel@savoirfairelinux.com,
	Damien Riegel <damien.riegel@savoirfairelinux.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit adds documentation for the Technologic Systems version of
SJA1000. The difference with the NXP version is in the way the registers
are accessed.

Signed-off-by: Damien Riegel <damien.riegel@savoirfairelinux.com>
---
 Documentation/devicetree/bindings/net/can/sja1000.txt | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/can/sja1000.txt b/Documentation/devicetree/bindings/net/can/sja1000.txt
index b4a6d53..7a158d5 100644
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
+	Must be set to 2 for technologic version.
 	Default to 1 (8 bits).
 
 - nxp,external-clock-frequency : Frequency of the external oscillator
-- 
2.5.0
