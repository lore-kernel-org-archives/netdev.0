From: Jay Purohit <jspurohit@velocitylimitless.com>
Subject: [PATCH] iPhone 5 support for ipheth.
Date: Thu, 11 Oct 2012 16:08:09 -0500
Message-ID: <CADx9NEdOWe1m2PnUcnr6VD7d-Cohr2mNu1FMih80hDD5Lic2BQ@mail.gmail.com>
References: <CADx9NEeyPUNrOiWHn97eOTp5skBqa7D9t8m_90QDAgs+kKtybg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:56126 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759057Ab2JKVIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 17:08:10 -0400
Received: by mail-vb0-f46.google.com with SMTP id ff1so2312903vbb.19
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 14:08:09 -0700 (PDT)
In-Reply-To: <CADx9NEeyPUNrOiWHn97eOTp5skBqa7D9t8m_90QDAgs+kKtybg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed that the iPhone ethernet driver did not support
iPhone 5. I quickly added support to it in my kernel, here's
a patch.

Signed-off-by: Jay Purohit <jspurohit@velocitylimitless.com>
Acked-by: Valdis Kletnieks <valdis.kletnieks@vt.edu>

--- linux-3.6.1/drivers/net/usb/ipheth.c        2012-10-07
10:41:28.000000000 -0500
+++ new/linux-3.6.1/drivers/net/usb/ipheth.c    2012-10-11
11:38:17.242000596 -0500
@@ -62,6 +62,8 @@
 #define USB_PRODUCT_IPAD 0x129a
 #define USB_PRODUCT_IPHONE_4_VZW 0x129c
 #define USB_PRODUCT_IPHONE_4S  0x12a0
+#define USB_PRODUCT_IPHONE_5   0x12a8
+

 #define IPHETH_USBINTF_CLASS    255
 #define IPHETH_USBINTF_SUBCLASS 253
@@ -113,6 +115,10 @@
                USB_VENDOR_APPLE, USB_PRODUCT_IPHONE_4S,
                IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
                IPHETH_USBINTF_PROTO) },
+       { USB_DEVICE_AND_INTERFACE_INFO(
+               USB_VENDOR_APPLE, USB_PRODUCT_IPHONE_5,
+               IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
+               IPHETH_USBINTF_PROTO) },
        { }
 };
 MODULE_DEVICE_TABLE(usb, ipheth_table);
