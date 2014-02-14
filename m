From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH] net: usb: sr9800: Use '%zu' to print size_t format
Date: Fri, 14 Feb 2014 11:25:35 -0200
Message-ID: <1392384335-19707-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liujunliang_ljl@163.com>, <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe005.messaging.microsoft.com ([216.32.180.188]:14794
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751288AbaBNNZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 08:25:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following build warning on ARM:

drivers/net/usb/sr9800.c:826:2: warning: format '%ld' expects argument of type 'long int', but argument 5 has type 'size_t' [-Wformat]

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/usb/sr9800.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/sr9800.c b/drivers/net/usb/sr9800.c
index 4175eb9..8017108 100644
--- a/drivers/net/usb/sr9800.c
+++ b/drivers/net/usb/sr9800.c
@@ -823,7 +823,7 @@ static int sr9800_bind(struct usbnet *dev, struct usb_interface *intf)
 		dev->rx_urb_size =
 			SR9800_BULKIN_SIZE[SR9800_MAX_BULKIN_2K].size;
 	}
-	netdev_dbg(dev->net, "%s : setting rx_urb_size with : %ld\n", __func__,
+	netdev_dbg(dev->net, "%s : setting rx_urb_size with : %zu\n", __func__,
 		   dev->rx_urb_size);
 	return 0;
 
-- 
1.8.1.2
