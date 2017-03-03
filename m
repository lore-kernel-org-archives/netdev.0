From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 4/4] can: flexcan: fix typo in comment
Date: Fri,  3 Mar 2017 14:55:35 +0100
Message-ID: <20170303135535.22937-5-mkl@pengutronix.de>
References: <20170303135535.22937-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:50281 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751590AbdCCN4K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 08:56:10 -0500
In-Reply-To: <20170303135535.22937-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the typo "Disble" -> "Disable".

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index ea57fed375c6..13f0f219d8aa 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -196,7 +196,7 @@
 #define FLEXCAN_QUIRK_BROKEN_ERR_STATE	BIT(1) /* [TR]WRN_INT not connected */
 #define FLEXCAN_QUIRK_DISABLE_RXFG	BIT(2) /* Disable RX FIFO Global mask */
 #define FLEXCAN_QUIRK_ENABLE_EACEN_RRS	BIT(3) /* Enable EACEN and RRS bit in ctrl2 */
-#define FLEXCAN_QUIRK_DISABLE_MECR	BIT(4) /* Disble Memory error detection */
+#define FLEXCAN_QUIRK_DISABLE_MECR	BIT(4) /* Disable Memory error detection */
 #define FLEXCAN_QUIRK_USE_OFF_TIMESTAMP	BIT(5) /* Use timestamp based offloading */
 
 /* Structure of the message buffer */
-- 
2.11.0
