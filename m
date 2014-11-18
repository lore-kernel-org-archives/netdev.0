From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 09/17] can: gs_usb: add .ndo_change_mtu function
Date: Tue, 18 Nov 2014 21:37:39 +0100
Message-ID: <1416343067-9810-10-git-send-email-mkl@pengutronix.de>
References: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47306 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932231AbaKRUiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 15:38:02 -0500
In-Reply-To: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use common can_change_mtu function.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/gs_usb.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/can/usb/gs_usb.c b/drivers/net/can/usb/gs_usb.c
index 04b0f84612f0..009acc8641fc 100644
--- a/drivers/net/can/usb/gs_usb.c
+++ b/drivers/net/can/usb/gs_usb.c
@@ -718,6 +718,7 @@ static const struct net_device_ops gs_usb_netdev_ops = {
 	.ndo_open = gs_can_open,
 	.ndo_stop = gs_can_close,
 	.ndo_start_xmit = gs_can_start_xmit,
+	.ndo_change_mtu = can_change_mtu,
 };
 
 static struct gs_can *gs_make_candev(unsigned int channel, struct usb_interface *intf)
-- 
2.1.3
