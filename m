From: akpm@linux-foundation.org
Subject: [patch 5/7] bluetooth: blacklist another Broadcom BCM2035 device
Date: Mon, 04 Feb 2008 23:48:17 -0800
Message-ID: <200802050747.m157lwwg010458@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	andy@smile.org.ua
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54010 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753848AbYBEHsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 02:48:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andy@smile.org.ua>

This device is recognized as bluetooth, but still not works.

Signed-off-by: Andy Shevchenko <andy@smile.org.ua>
Cc: Marcel Holtmann <marcel@holtmann.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/bluetooth/hci_usb.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN drivers/bluetooth/hci_usb.c~bluetooth-blacklist-another-broadcom-bcm2035-device drivers/bluetooth/hci_usb.c
--- a/drivers/bluetooth/hci_usb.c~bluetooth-blacklist-another-broadcom-bcm2035-device
+++ a/drivers/bluetooth/hci_usb.c
@@ -111,6 +111,7 @@ static struct usb_device_id blacklist_id
 	{ USB_DEVICE(0x0a5c, 0x2033), .driver_info = HCI_IGNORE },
 
 	/* Broadcom BCM2035 */
+	{ USB_DEVICE(0x0a5c, 0x2035), .driver_info = HCI_RESET | HCI_WRONG_SCO_MTU },
 	{ USB_DEVICE(0x0a5c, 0x200a), .driver_info = HCI_RESET | HCI_WRONG_SCO_MTU },
 	{ USB_DEVICE(0x0a5c, 0x2009), .driver_info = HCI_BCM92035 },
 
_
