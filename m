From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next] net: cx82310_eth: use common match macro
Date: Mon,  3 Sep 2012 11:20:31 +0200
Message-ID: <1346664033-30284-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:47179 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752386Ab2ICJUm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2012 05:20:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cx82310_eth.c |   11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/drivers/net/usb/cx82310_eth.c b/drivers/net/usb/cx82310_et=
h.c
index 49ab45e..1e207f0 100644
--- a/drivers/net/usb/cx82310_eth.c
+++ b/drivers/net/usb/cx82310_eth.c
@@ -302,18 +302,9 @@ static const struct driver_info	cx82310_info =3D {
 	.tx_fixup	=3D cx82310_tx_fixup,
 };
=20
-#define USB_DEVICE_CLASS(vend, prod, cl, sc, pr) \
-	.match_flags =3D USB_DEVICE_ID_MATCH_DEVICE | \
-		       USB_DEVICE_ID_MATCH_DEV_INFO, \
-	.idVendor =3D (vend), \
-	.idProduct =3D (prod), \
-	.bDeviceClass =3D (cl), \
-	.bDeviceSubClass =3D (sc), \
-	.bDeviceProtocol =3D (pr)
-
 static const struct usb_device_id products[] =3D {
 	{
-		USB_DEVICE_CLASS(0x0572, 0xcb01, 0xff, 0, 0),
+		USB_DEVICE_AND_INTERFACE_INFO(0x0572, 0xcb01, 0xff, 0, 0),
 		.driver_info =3D (unsigned long) &cx82310_info
 	},
 	{ },
--=20
1.7.10.4
