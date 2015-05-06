From: Vasily Titskiy <qehgt0@gmail.com>
Subject: [PATCH-2] drivers/net/usb: Add support for 'Lenovo OneLink Pro Dock'
Date: Wed, 6 May 2015 10:31:21 -0400
Message-ID: <20150506143120.GA1595@ubuntu-build.winmagic.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:34883 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752684AbbEFObY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 10:31:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This device is sold as 'Lenovo OneLink Pro Dock'.
Chipset is RTL8153 and works with r8152.

Signed-off-by: Vasily Titskiy <qehgt0@gmail.com>
---
 drivers/net/usb/r8152.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index ac4d03b..aafa1a1 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -4116,6 +4116,7 @@ static struct usb_device_id rtl8152_table[] = {
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8153)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_SAMSUNG, 0xa101)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x7205)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x304f)},
 	{}
 };
 
-- 
1.9.1
