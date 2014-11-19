From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 07/10] dt/bindings: reformat micrel eth-phy documentation
Date: Wed, 19 Nov 2014 12:59:20 +0100
Message-ID: <1416398363-32306-8-git-send-email-johan@kernel.org>
References: <1416398363-32306-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Bruno Thomsen <bth@kamstrup.dk>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Mark Rutland <mark.rutland@arm.com>,
	Johan Hovold <johan@kernel.org>, devicetree@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416398363-32306-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduce indentation of Micrel PHY binding documentations somewhat.

Also fix "reference input clock" typo while at it.

Cc: devicetree@vger.kernel.org
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 Documentation/devicetree/bindings/net/micrel.txt | 26 ++++++++++++------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/micrel.txt b/Documentation/devicetree/bindings/net/micrel.txt
index a1bab5eaae02..20a6cac7abc6 100644
--- a/Documentation/devicetree/bindings/net/micrel.txt
+++ b/Documentation/devicetree/bindings/net/micrel.txt
@@ -6,21 +6,21 @@ Optional properties:
 
  - micrel,led-mode : LED mode value to set for PHYs with configurable LEDs.
 
-              Configure the LED mode with single value. The list of PHYs and
-	      the bits that are currently supported:
+	Configure the LED mode with single value. The list of PHYs and the
+	bits that are currently supported:
 
-	      KSZ8001: register 0x1e, bits 15..14
-	      KSZ8041: register 0x1e, bits 15..14
-	      KSZ8021: register 0x1f, bits 5..4
-	      KSZ8031: register 0x1f, bits 5..4
-	      KSZ8051: register 0x1f, bits 5..4
-	      KSZ8081: register 0x1f, bits 5..4
-	      KSZ8091: register 0x1f, bits 5..4
+	KSZ8001: register 0x1e, bits 15..14
+	KSZ8041: register 0x1e, bits 15..14
+	KSZ8021: register 0x1f, bits 5..4
+	KSZ8031: register 0x1f, bits 5..4
+	KSZ8051: register 0x1f, bits 5..4
+	KSZ8081: register 0x1f, bits 5..4
+	KSZ8091: register 0x1f, bits 5..4
 
-              See the respective PHY datasheet for the mode values.
+	See the respective PHY datasheet for the mode values.
 
  - clocks, clock-names: contains clocks according to the common clock bindings.
 
-              supported clocks:
-	      - KSZ8021, KSZ8031, KSZ8081, KSZ8091: "rmii-ref": The RMII
-		refence input clock. Used to determine the XI input clock.
+	supported clocks:
+	- KSZ8021, KSZ8031, KSZ8081, KSZ8091: "rmii-ref": The RMII reference
+	  input clock. Used to determine the XI input clock.
-- 
2.0.4
