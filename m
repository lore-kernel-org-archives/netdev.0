From: Florian Vaussard <florian.vaussard@epfl.ch>
Subject: [PATCH v2 5/6] Documentation: devicetree: sja1000: add reg-io-width binding
Date: Fri, 31 Jan 2014 11:35:12 +0100
Message-ID: <1391164513-11529-6-git-send-email-florian.vaussard@epfl.ch>
References: <1391164513-11529-1-git-send-email-florian.vaussard@epfl.ch>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, florian.vaussard@epfl.ch,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, devicetree@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.epfl.ch ([128.178.224.219]:37468 "EHLO smtp4.epfl.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753649AbaAaKfb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Jan 2014 05:35:31 -0500
In-Reply-To: <1391164513-11529-1-git-send-email-florian.vaussard@epfl.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
1.8.1.2
