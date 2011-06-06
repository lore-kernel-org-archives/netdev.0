From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 05/11] can: at91_can: directly define AT91_MB_RX_LAST
Date: Mon,  6 Jun 2011 15:42:54 +0200
Message-ID: <1307367780-30715-6-git-send-email-mkl@pengutronix.de>
References: <1307367780-30715-1-git-send-email-mkl@pengutronix.de>
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48444 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757072Ab1FFNnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 09:43:13 -0400
In-Reply-To: <1307367780-30715-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

...instead of deriving it from AT91_MB_RX_FIRST and AT91_MB_RX_NUM.
This removes a level of computation, when switching the driver from
compile time constants to runtime values.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/at91_can.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 716f22b..9ce00fa 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -47,11 +47,10 @@
  * RX/TX Mailbox split
  * don't dare to touch
  */
-#define AT91_MB_RX_NUM		11
 #define AT91_MB_TX_SHIFT	2
 
 #define AT91_MB_RX_FIRST	1
-#define AT91_MB_RX_LAST		(AT91_MB_RX_FIRST + AT91_MB_RX_NUM - 1)
+#define AT91_MB_RX_LAST		11
 
 #define AT91_MB_RX_MASK(i)	((1 << (i)) - 1)
 #define AT91_MB_RX_SPLIT	8
-- 
1.7.4.1

