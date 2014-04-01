From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 02/16] can: Documentation: fix parameter name "sample-point"
Date: Tue,  1 Apr 2014 23:42:16 +0200
Message-ID: <1396388550-23081-3-git-send-email-mkl@pengutronix.de>
References: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Robert Schwebel <r.schwebel@pengutronix.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Schwebel <r.schwebel@pengutronix.de>

This patch fixes the name of the parameter to configure the sample point used
in iproute2's ip command. The correct writing is "sample-point" not
"sample_point".

Signed-off-by: Robert Schwebel <r.schwebel@pengutronix.de>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 Documentation/networking/can.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/networking/can.txt b/Documentation/networking/can.txt
index 0cbe6ec..2fa44cb 100644
--- a/Documentation/networking/can.txt
+++ b/Documentation/networking/can.txt
@@ -1017,7 +1017,7 @@ solution for a couple of reasons:
 	in case of a bus-off condition after the specified delay time
 	in milliseconds. By default it's off.
 
-    "bitrate 125000 sample_point 0.875"
+    "bitrate 125000 sample-point 0.875"
 	Shows the real bit-rate in bits/sec and the sample-point in the
 	range 0.000..0.999. If the calculation of bit-timing parameters
 	is enabled in the kernel (CONFIG_CAN_CALC_BITTIMING=y), the
-- 
1.9.0.279.gdc9e3eb

