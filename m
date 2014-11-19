From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 08/10] dt/bindings: add clock-select function property to micrel phy binding
Date: Wed, 19 Nov 2014 12:59:21 +0100
Message-ID: <1416398363-32306-9-git-send-email-johan@kernel.org>
References: <1416398363-32306-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Bruno Thomsen <bth@kamstrup.dk>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Mark Rutland <mark.rutland@arm.com>,
	Johan Hovold <johan@kernel.org>, devicetree@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:48320 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960AbaKSL7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 06:59:50 -0500
In-Reply-To: <1416398363-32306-1-git-send-email-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add "micrel,rmii-reference-clock-select-25-mhz" to Micrel ethernet PHY
binding documentation.

This property is needed to properly describe some revisions of Micrel
PHYs which has the function of this configuration bit inverted so that
setting it enables 25 MHz rather than 50 MHz clock mode.

Note that a clock reference ("rmii-ref") is still needed to actually
select either mode.

Cc: devicetree@vger.kernel.org
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 Documentation/devicetree/bindings/net/micrel.txt | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/micrel.txt b/Documentation/devicetree/bindings/net/micrel.txt
index 20a6cac7abc6..87496a8c64ab 100644
--- a/Documentation/devicetree/bindings/net/micrel.txt
+++ b/Documentation/devicetree/bindings/net/micrel.txt
@@ -19,6 +19,17 @@ Optional properties:
 
 	See the respective PHY datasheet for the mode values.
 
+ - micrel,rmii-reference-clock-select-25-mhz: RMII Reference Clock Select
+						bit selects 25 MHz mode
+
+	Setting the RMII Reference Clock Select bit enables 25 MHz rather
+	than 50 MHz clock mode.
+
+	Note that this option in only needed for certain PHY revisions with a
+	non-standard, inverted function of this configuration bit.
+	Specifically, a clock reference ("rmii-ref" below) is always needed to
+	actually select a mode.
+
  - clocks, clock-names: contains clocks according to the common clock bindings.
 
 	supported clocks:
-- 
2.0.4
