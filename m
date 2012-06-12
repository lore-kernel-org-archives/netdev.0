From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 5/7] usbnet: remove flag of EVENT_DEV_WAKING
Date: Tue, 12 Jun 2012 09:19:43 +0800
Message-ID: <1339463985-9006-6-git-send-email-tom.leiming@gmail.com>
References: <1339463985-9006-1-git-send-email-tom.leiming@gmail.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <tom.leiming@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:51886 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753151Ab2FLBUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 21:20:51 -0400
In-Reply-To: <1339463985-9006-1-git-send-email-tom.leiming@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The flag of EVENT_DEV_WAKING is not used any more, so just remove it.

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 include/linux/usb/usbnet.h |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index f15a729..b994c0f 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -66,8 +66,7 @@ struct usbnet {
 #		define EVENT_STS_SPLIT	3
 #		define EVENT_LINK_RESET	4
 #		define EVENT_RX_PAUSED	5
-#		define EVENT_DEV_WAKING 6
-#		define EVENT_DEV_ASLEEP 7
+#		define EVENT_DEV_ASLEEP 6
 };
 
 static inline struct usb_driver *driver_of(struct usb_interface *intf)
-- 
1.7.9.5
