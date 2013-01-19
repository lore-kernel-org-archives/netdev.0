From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH net-next] net: asix: ax88772_unbind() can be static
Date: Sat, 19 Jan 2013 09:36:56 +0800
Message-ID: <20130119013656.GA15200@localhost>
References: <50f9b5d8.Por1KFVVV30/pKOM%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lucas Stach <dev@lynxeye.de>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41354 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755734Ab3ASBhB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 20:37:01 -0500
Content-Disposition: inline
In-Reply-To: <50f9b5d8.Por1KFVVV30/pKOM%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 drivers/net/usb/asix_devices.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next.orig/drivers/net/usb/asix_devices.c	2013-01-19 08:27:36.199070226 +0800
+++ linux-next/drivers/net/usb/asix_devices.c	2013-01-19 09:33:49.567164656 +0800
@@ -502,7 +502,7 @@ static int ax88772_bind(struct usbnet *d
 	return 0;
 }
 
-void ax88772_unbind(struct usbnet *dev, struct usb_interface *intf)
+static void ax88772_unbind(struct usbnet *dev, struct usb_interface *intf)
 {
 	if (dev->driver_priv)
 		kfree(dev->driver_priv);
