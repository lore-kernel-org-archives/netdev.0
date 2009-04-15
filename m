From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH -next 2/3] usbnet: remove old compat_net_dev_ops code
Date: Wed, 15 Apr 2009 21:58:28 +0400
Message-ID: <1239818309-14899-2-git-send-email-a.beregalov@gmail.com>
References: <1239818309-14899-1-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.190]:29635 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752849AbZDOR6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 13:58:48 -0400
Received: by ti-out-0910.google.com with SMTP id 11so6496tim.23
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 10:58:47 -0700 (PDT)
In-Reply-To: <1239818309-14899-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since all usb network drivers are already converted to net_device_ops
this code is useless.

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/usb/usbnet.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index f3a2fce..2b8b903 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1185,12 +1185,6 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 #endif
 
 	net->netdev_ops = &usbnet_netdev_ops;
-#ifdef CONFIG_COMPAT_NET_DEV_OPS
-	net->hard_start_xmit = usbnet_start_xmit;
-	net->open = usbnet_open;
-	net->stop = usbnet_stop;
-	net->tx_timeout = usbnet_tx_timeout;
-#endif
 	net->watchdog_timeo = TX_TIMEOUT_JIFFIES;
 	net->ethtool_ops = &usbnet_ethtool_ops;
 
-- 
1.6.2.3

