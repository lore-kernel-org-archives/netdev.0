From: Rene Rebe <rene@exactcode.com>
Subject: [PATCH] r8152 add Microsoft Dock IDs
Date: Thu, 14 Jan 2016 18:46:26 +0100 (CET)
Message-ID: <20160114.184626.1327276960383833164.rene@exactcode.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.exactcode.de ([144.76.154.42]:46546 "EHLO mx.exactcode.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756281AbcANRql convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 12:46:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,
(my appologies for wasting your time with this noise)

rebased against your netdev git, and sent with Mew:

The Microsoft Surface Docks uses a R8152, too.

Signed-off-by: Ren=E9 Rebe <rene@exactcode.com>

--- linux-git/drivers/net/usb/r8152.c.orig	2016-01-14 15:17:54.78666245=
6 +0100
+++ linux-git/drivers/net/usb/r8152.c	2016-01-14 15:17:21.050661823 +01=
00
@@ -504,6 +504,7 @@
=20
 /* Define these values to match your device */
 #define VENDOR_ID_REALTEK		0x0bda
+#define VENDOR_ID_MICROSOFT		0x045e
 #define VENDOR_ID_SAMSUNG		0x04e8
 #define VENDOR_ID_LENOVO		0x17ef
 #define VENDOR_ID_NVIDIA		0x0955
@@ -4294,6 +4295,8 @@
 static struct usb_device_id rtl8152_table[] =3D {
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8152)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8153)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_MICROSOFT, 0x07ab)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_MICROSOFT, 0x07c6)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_SAMSUNG, 0xa101)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x7205)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x304f)},


--=20
  Ren=E9 Rebe, ExactCODE GmbH, Lietzenburger Str. 42, DE-10117 Berlin
  http://exactcode.com | http://t2-project.org | http://rene.rebe.de
