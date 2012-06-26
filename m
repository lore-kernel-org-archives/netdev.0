From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH 1/2] net: flexcan: clock-frequency is optional for device tree probe
Date: Tue, 26 Jun 2012 16:49:22 +0800
Message-ID: <1340700563-8386-2-git-send-email-shawn.guo@linaro.org>
References: <1340700563-8386-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	Shawn Guo <shawn.guo@linaro.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe005.messaging.microsoft.com ([213.199.154.208]:15527
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751088Ab2FZItZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 04:49:25 -0400
In-Reply-To: <1340700563-8386-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The property clock-frequency is optional for device tree probe.  When
it's absent, the flexcan driver will try to get the frequency from clk
system by calling clk_get_rate.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 .../devicetree/bindings/net/can/fsl-flexcan.txt    |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt b/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
index f31b686..8ff324e 100644
--- a/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
+++ b/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
@@ -11,6 +11,9 @@ Required properties:
 
 - reg : Offset and length of the register set for this device
 - interrupts : Interrupt tuple for this device
+
+Optional properties:
+
 - clock-frequency : The oscillator frequency driving the flexcan device
 
 Example:
-- 
1.7.5.4
