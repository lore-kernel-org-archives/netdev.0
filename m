From: Rene Rebe <rene@exactcode.com>
Subject: [PATCH] r8152: The Microsoft Surface docks also use R8152.
Date: Tue, 28 Mar 2017 06:42:15 +0200 (CEST)
Message-ID: <20170328.064215.1055636797214516339.rene@exactcode.com>
References: <20160113.145146.20282510666434086.davem@davemloft.net>
        <04D87F8E-0A8C-4DEC-AE66-35D9B6B0E7B7@exactcode.com>
        <20160113.154941.1886033351271894428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.exactcode.de ([144.76.154.42]:49660 "EHLO mx.exactcode.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932582AbdC3Qxi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 12:53:38 -0400
In-Reply-To: <20160113.154941.1886033351271894428.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this the generic cdc_ether grabs the device,
and does not really work.

Signed-off-by: René Rebe <rene@exactcode.com>

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index c34df33..07f788c 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -517,6 +517,7 @@ enum rtl8152_flags {
 
 /* Define these values to match your device */
 #define VENDOR_ID_REALTEK		0x0bda
+#define VENDOR_ID_MICROSOFT		0x045e
 #define VENDOR_ID_SAMSUNG		0x04e8
 #define VENDOR_ID_LENOVO		0x17ef
 #define VENDOR_ID_NVIDIA		0x0955
@@ -4521,6 +4522,8 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 static struct usb_device_id rtl8152_table[] = {
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8152)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8153)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_MICROSOFT, 0x07ab)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_MICROSOFT, 0x07c6)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_SAMSUNG, 0xa101)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x304f)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x3062)},


-- 
  René Rebe, ExactCODE GmbH, Lietzenburger Str. 42, DE-10789 Berlin
  http://exactcode.com | http://t2-project.org | http://rene.rebe.de
