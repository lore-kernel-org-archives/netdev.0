From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 08/17] can: rcar_can: add .ndo_change_mtu function
Date: Tue, 18 Nov 2014 21:37:38 +0100
Message-ID: <1416343067-9810-9-git-send-email-mkl@pengutronix.de>
References: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47302 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932224AbaKRUiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 15:38:02 -0500
In-Reply-To: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use common can_change_mtu function.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/rcar_can.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/can/rcar_can.c b/drivers/net/can/rcar_can.c
index 1abe133d1594..9718248e55f1 100644
--- a/drivers/net/can/rcar_can.c
+++ b/drivers/net/can/rcar_can.c
@@ -628,6 +628,7 @@ static const struct net_device_ops rcar_can_netdev_ops = {
 	.ndo_open = rcar_can_open,
 	.ndo_stop = rcar_can_close,
 	.ndo_start_xmit = rcar_can_start_xmit,
+	.ndo_change_mtu = can_change_mtu,
 };
 
 static void rcar_can_rx_pkt(struct rcar_can_priv *priv)
-- 
2.1.3
