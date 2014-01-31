From: Florian Vaussard <florian.vaussard@epfl.ch>
Subject: [PATCH v3 4/5] Documentation: devicetree: sja1000: add reg-io-width binding
Date: Fri, 31 Jan 2014 14:34:36 +0100
Message-ID: <1391175277-19833-5-git-send-email-florian.vaussard@epfl.ch>
References: <1391175277-19833-1-git-send-email-florian.vaussard@epfl.ch>
Cc: Andreas Larsson <andreas@gaisler.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, sparclinux@vger.kernel.org,
	linux-kernel@vger.kernel.org, florian.vaussard@epfl.ch,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, devicetree@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391175277-19833-1-git-send-email-florian.vaussard@epfl.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
