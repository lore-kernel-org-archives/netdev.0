From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 10/11] usbnet: apply usbnet_link_change
Date: Thu, 11 Apr 2013 22:40:39 +0800
Message-ID: <1365691240-816-11-git-send-email-ming.lei@canonical.com>
References: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:56215 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161509Ab3DKOl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 10:41:57 -0400
In-Reply-To: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use usbnet_link_change to handle link change centrally.

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/usbnet.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 40e4237..34e4252 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1521,7 +1521,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	netif_device_attach (net);
 
 	if (dev->driver_info->flags & FLAG_LINK_INTR)
-		netif_carrier_off(net);
+		usbnet_link_change(dev, 0, 0);
 
 	return 0;
 
-- 
1.7.9.5
