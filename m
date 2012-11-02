From: Jaume =?iso-8859-1?Q?Delcl=F2s?= Coll <jaume@delclos.com>
Subject: [PATCH] Wireless: rt2x00: Add device id for Sweex LW323 to
 rt2800usb.c
Date: Fri, 2 Nov 2012 23:35:20 +0100
Message-ID: <20121102223520.GB16573@jaume-arch.example.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: IvDoorn@gmail.com, gwingerde@gmail.com,
	helmut.schaa@googlemail.com, linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Jaume Delcl=F2s <jaume@delclos.com>

This patch adds detection for the Sweex LW323 USB wireless network card
in the rt2x00 driver (just one line in rt2800usb.c).
It applies to linux-3.7-rc3.

Signed-off-by: Jaume Delcl=F2s <jaume@delclos.com>

--- linux-3.7-rc3/drivers/net/wireless/rt2x00/rt2800usb.c.orig	2012-11-=
02 21:14:01.393082623 +0100
+++ linux-3.7-rc3/drivers/net/wireless/rt2x00/rt2800usb.c	2012-11-02 21=
:14:57.502778651 +0100
@@ -1096,6 +1096,7 @@ static struct usb_device_id rt2800usb_de
 	{ USB_DEVICE(0x177f, 0x0153) },
 	{ USB_DEVICE(0x177f, 0x0302) },
 	{ USB_DEVICE(0x177f, 0x0313) },
+	{ USB_DEVICE(0x177f, 0x0323) },
 	/* U-Media */
 	{ USB_DEVICE(0x157e, 0x300e) },
 	{ USB_DEVICE(0x157e, 0x3013) },
