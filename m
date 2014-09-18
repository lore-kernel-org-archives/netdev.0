From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 7/8] can: flexcan: increase FLEXCAN_MCR_MAXMB() macro to 7 bits
Date: Thu, 18 Sep 2014 12:41:01 +0200
Message-ID: <1411036862-13255-8-git-send-email-mkl@pengutronix.de>
References: <1411036862-13255-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37913 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756574AbaIRKlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 06:41:14 -0400
In-Reply-To: <1411036862-13255-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch increases the mask in the FLEXCAN_MCR_MAXMB() to 7 bits as in the
newer flexcan cores the MAXMB field is 7 bits wide.

Reported-by: David Jander <david@protonic.nl>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index c17ae9e..6586309 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -62,7 +62,7 @@
 #define FLEXCAN_MCR_BCC			BIT(16)
 #define FLEXCAN_MCR_LPRIO_EN		BIT(13)
 #define FLEXCAN_MCR_AEN			BIT(12)
-#define FLEXCAN_MCR_MAXMB(x)		((x) & 0x1f)
+#define FLEXCAN_MCR_MAXMB(x)		((x) & 0x7f)
 #define FLEXCAN_MCR_IDAM_A		(0 << 8)
 #define FLEXCAN_MCR_IDAM_B		(1 << 8)
 #define FLEXCAN_MCR_IDAM_C		(2 << 8)
-- 
2.1.0
