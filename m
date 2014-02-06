From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH v4 4/5] Documentation: devicetree: sja1000: add reg-io-width binding
Date: Thu,  6 Feb 2014 12:09:55 +0100
Message-ID: <1391684996-612-5-git-send-email-mkl@pengutronix.de>
References: <1391684996-612-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org,
	Florian Vaussard <florian.vaussard@epfl.ch>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, devicetree@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46265 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756066AbaBFLKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 06:10:04 -0500
In-Reply-To: <1391684996-612-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Vaussard <florian.vaussard@epfl.ch>

Add the reg-io-width property to describe the width of the memory
accesses.

Cc: Grant Likely <grant.likely@linaro.org>
Cc: Rob Herring <robh+dt@kernel.org>
Cc: Pawel Moll <pawel.moll@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Ian Campbell <ijc+devicetree@hellion.org.uk>
Cc: Kumar Gala <galak@codeaurora.org>
Cc: devicetree@vger.kernel.org
Acked-by: Rob Herring <robh@kernel.org>
Signed-off-by: Florian Vaussard <florian.vaussard@epfl.ch>
Tested-by: Andreas Larsson <andreas@gaisler.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 Documentation/devicetree/bindings/net/can/sja1000.txt | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/can/sja1000.txt b/Documentation/devicetree/bindings/net/can/sja1000.txt
index f2105a4..b4a6d53 100644
--- a/Documentation/devicetree/bindings/net/can/sja1000.txt
+++ b/Documentation/devicetree/bindings/net/can/sja1000.txt
@@ -12,6 +12,10 @@ Required properties:
 
 Optional properties:
 
+- reg-io-width : Specify the size (in bytes) of the IO accesses that
+	should be performed on the device.  Valid value is 1, 2 or 4.
+	Default to 1 (8 bits).
+
 - nxp,external-clock-frequency : Frequency of the external oscillator
 	clock in Hz. Note that the internal clock frequency used by the
 	SJA1000 is half of that value. If not specified, a default value
-- 
1.8.5.3
