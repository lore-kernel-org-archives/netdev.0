From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATH]
Date: Thu, 14 Jan 2016 18:00:39 +0100
Message-ID: <20160114170039.GB3967@nanopsycho.orion>
References: <20160114.152106.1522848878187628539.rene@exactcode.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Rene Rebe <rene@exactcode.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:34484 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752410AbcANRAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 12:00:43 -0500
Received: by mail-wm0-f51.google.com with SMTP id u188so356862837wmu.1
        for <netdev@vger.kernel.org>; Thu, 14 Jan 2016 09:00:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160114.152106.1522848878187628539.rene@exactcode.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The subject is absolutelly wrong. Please do it properly.

Also, you can use "git format-patch" to create patch and "git
send-email" to send it. That makes your life a bit easier.

Also, please use "scripts/checkpatch.pl" to check you patch (that would
warn you about bad subject line) and "scripts/get_maintainer.pl" to fin=
d
out who to put on cc list.

Thanks.

Thu, Jan 14, 2016 at 03:21:06PM CET, rene@exactcode.com wrote:
>Hi David,
>
>rebased against your netdev git, and sent with Mew:
>
>The Microsoft Surface Docks uses a R8152, too.
>
>Signed-off-by: Ren=E9 Rebe <rene@exactcode.com>
>
>--- linux-git/drivers/net/usb/r8152.c.orig	2016-01-14 15:17:54.7866624=
56 +0100
>+++ linux-git/drivers/net/usb/r8152.c	2016-01-14 15:17:21.050661823 +0=
100
>@@ -504,6 +504,7 @@
>=20
> /* Define these values to match your device */
> #define VENDOR_ID_REALTEK		0x0bda
>+#define VENDOR_ID_MICROSOFT		0x045e
> #define VENDOR_ID_SAMSUNG		0x04e8
> #define VENDOR_ID_LENOVO		0x17ef
> #define VENDOR_ID_NVIDIA		0x0955
>@@ -4294,6 +4295,8 @@
> static struct usb_device_id rtl8152_table[] =3D {
> 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8152)},
> 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8153)},
>+	{REALTEK_USB_DEVICE(VENDOR_ID_MICROSOFT, 0x07ab)},
>+	{REALTEK_USB_DEVICE(VENDOR_ID_MICROSOFT, 0x07c6)},
> 	{REALTEK_USB_DEVICE(VENDOR_ID_SAMSUNG, 0xa101)},
> 	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x7205)},
> 	{REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x304f)},
>
>
>--=20
>  Ren=E9 Rebe, ExactCODE GmbH, Lietzenburger Str. 42, DE-10117 Berlin
>  http://exactcode.com | http://t2-project.org | http://rene.rebe.de
