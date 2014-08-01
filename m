From: jflf-kernel@gmx.com
Subject: [PATCH] r8152: add missing Makefile rule
Date: Sat, 02 Aug 2014 01:26:40 +0200
Message-ID: <53DC2230.9010504@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nic_swsd@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:49684 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754620AbaHAX0t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 19:26:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: JF Le Fillatre <jflf-kernel@gmx.com>

Add missing Makefile rule for r8152 driver

In the current kernel the r8152 driver is *never* built because of a missing rule in drivers/net/Makefile, despite being selected as built-in or module in the .config file. There is no error message or warning to indicate that the driver isn't built. This change adds the rule and lets the driver build.

Tested as built-in and module for 3.15.8.

Signed-off by: JF Le Fillatre <jflf-kernel@gmx.com>

---

 Is seems that this issue has existed ever since the driver was added back in 3.10. In Linus' git tree the drivers/net/Makefile was last modified before the inclusion of the driver, so I don't know if it's ever been possible to build it.


--- linux-3.15.8/drivers/net/Makefile.orig    2014-08-01 21:51:43.058347887 +0200
+++ linux-3.15.8/drivers/net/Makefile    2014-08-01 21:52:15.418345294 +0200
@@ -65,6 +65,7 @@ obj-$(CONFIG_USB_CATC)          += usb/
 obj-$(CONFIG_USB_KAWETH)        += usb/
 obj-$(CONFIG_USB_PEGASUS)       += usb/
 obj-$(CONFIG_USB_RTL8150)       += usb/
+obj-$(CONFIG_USB_RTL8152)       += usb/
 obj-$(CONFIG_USB_HSO)        += usb/
 obj-$(CONFIG_USB_USBNET)        += usb/
 obj-$(CONFIG_USB_ZD1201)        += usb/
