From: =?windows-1252?Q?Ren=E9_Rebe?= <rene@exactcode.com>
Subject: Re: [PATCH] r8152 add Microsoft Dock IDs
Date: Wed, 13 Jan 2016 21:03:30 +0100
Message-ID: <04D87F8E-0A8C-4DEC-AE66-35D9B6B0E7B7@exactcode.com>
References: <904D0AF9-5265-47F5-A8DD-5A926438FE45@exactcode.com> <20160113.145146.20282510666434086.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.exactcode.de ([144.76.154.42]:45010 "EHLO mx.exactcode.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752213AbcAMUDo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 15:03:44 -0500
In-Reply-To: <20160113.145146.20282510666434086.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Jan 13, 2016, at 20:51, David Miller <davem@davemloft.net> wrote:

> Your patch was corrupted by your email client.

Ieek, guess that=92s what I get from not using Mew on my Ultra5 anymore=
 :-/
Crossing fingers it works this time, ...

The Microsoft Surface Docks uses a R8152, too.

Signed-off-by: Ren=E9 Rebe <rene@exactcode.com>

--- linux-3.19/drivers/net/usb/r8152.c.orig	2015-02-09 02:54:22.0000000=
00 +0000
+++ linux-3.19/drivers/net/usb/r8152.c	2015-02-15 15:52:52.924000000 +0=
000
@@ -462,6 +462,7 @@
=20
 /* Define these values to match your device */
 #define VENDOR_ID_REALTEK		0x0bda
+#define VENDOR_ID_MICROSOFT		0x045e
 #define VENDOR_ID_SAMSUNG		0x04e8
=20
 #define MCU_TYPE_PLA			0x0100
@@ -3932,6 +3933,8 @@
 static struct usb_device_id rtl8152_table[] =3D {
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8152)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8153)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_MICROSOFT, 0x07ab)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_MICROSOFT, 0x07c6)},
 	{REALTEK_USB_DEVICE(VENDOR_ID_SAMSUNG, 0xa101)},
 	{}
 };

--=20
 ExactCODE GmbH, Lietzenburger Str. 42, DE-10789 Berlin
 http://exactcode.com | http://exactscan.com | http://ocrkit.com | http=
://t2-project.org | http://rene.rebe.de
