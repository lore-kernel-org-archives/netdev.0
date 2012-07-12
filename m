From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] net: qmi_wwan: add ZTE MF821D
Date: Thu, 12 Jul 2012 13:18:26 +0200
Message-ID: <1342091906-30045-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Thomas=20Sch=C3=A4fer?= <tschaefer@t-online.de>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48301 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495Ab2GLLSm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 07:18:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sold by O2 (telefonica germany) under the name "LTE4G"

Tested-by: Thomas Sch=C3=A4fer <tschaefer@t-online.de>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
I've verified that this applies cleanly to both net and net-next.=20
Please apply to the branch you find appropriate.

Thanks,
Bj=C3=B8rn


 drivers/net/usb/qmi_wwan.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index a051ced..62c5ba2 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -453,6 +453,15 @@ static const struct usb_device_id products[] =3D {
 		.bInterfaceProtocol =3D 0xff,
 		.driver_info        =3D (unsigned long)&qmi_wwan_force_int4,
 	},
+	{	/* ZTE MF821D */
+		.match_flags        =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_M=
ATCH_INT_INFO,
+		.idVendor           =3D 0x19d2,
+		.idProduct          =3D 0x0326,
+		.bInterfaceClass    =3D 0xff,
+		.bInterfaceSubClass =3D 0xff,
+		.bInterfaceProtocol =3D 0xff,
+		.driver_info        =3D (unsigned long)&qmi_wwan_force_int4,
+	},
 	{	/* ZTE (Vodafone) K3520-Z */
 		.match_flags	    =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATC=
H_INT_INFO,
 		.idVendor           =3D 0x19d2,
--=20
1.7.10.4
