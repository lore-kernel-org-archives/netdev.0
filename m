From: Chris Clayton <chris2553@googlemail.com>
Subject: Fwd: [PATCH] Fix cdc-phonet build
Date: Tue, 26 Jul 2011 23:20:22 +0100
Message-ID: <201107262320.22338.chris2553@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38064 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753112Ab1GZVU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2011 17:20:27 -0400
Received: by wyg8 with SMTP id 8so528547wyg.19
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2011 14:20:25 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Try to send to correct address this time!

----------  Forwarded Message  ----------

Subject: [PATCH] Fix cdc-phonet build
Date: Saturday 23 Jul 2011
From: Chris Clayton <chris2553@googlemail.com>
To: linux-net@vger.kernel.org

cdc-phonet does not presently build on linux-3.0 because there is no entry for it in 
drivers/net/Makefile. This patch adds that entry.

Signed-off-by: Chris Clayton <chris2553@googlemail.com>
---

--- linux-3.0/drivers/net/Makefile.orig 2011-07-23 22:07:45.000000000 +0100
+++ linux-3.0/drivers/net/Makefile      2011-07-23 22:10:33.000000000 +0100
@@ -283,6 +283,7 @@
 obj-$(CONFIG_USB_USBNET)        += usb/
 obj-$(CONFIG_USB_ZD1201)        += usb/
 obj-$(CONFIG_USB_IPHETH)        += usb/
+obj-$(CONFIG_USB_CDC_PHONET)   += usb/

 obj-$(CONFIG_WLAN) += wireless/
 obj-$(CONFIG_NET_TULIP) += tulip/

-------------------------------------------------------

-- 
The more I see, the more I know. The more I know, the less I understand. Changing Man - Paul Weller
