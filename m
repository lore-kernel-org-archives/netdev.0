From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH] net: qmi_wwan: Add Vodafone/Huawei K5005 support
Date: Sat, 19 May 2012 19:20:31 +0200
Message-ID: <1337448031-16897-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Thomas=20Sch=C3=A4fer?= <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tested-by: Thomas Sch=C3=A4fer <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/qmi_wwan.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 9048efe..346d4a6 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -401,6 +401,14 @@ static const struct usb_device_id products[] =3D {
 		.bInterfaceProtocol =3D 8, /* NOTE: This is the *slave* interface of=
 the CDC Union! */
 		.driver_info        =3D (unsigned long)&qmi_wwan_info,
 	},
+	{	/* Vodafone/Huawei K5005 (12d1:14c8) and similar modems */
+		.match_flags        =3D USB_DEVICE_ID_MATCH_VENDOR | USB_DEVICE_ID_M=
ATCH_INT_INFO,
+		.idVendor           =3D HUAWEI_VENDOR_ID,
+		.bInterfaceClass    =3D USB_CLASS_VENDOR_SPEC,
+		.bInterfaceSubClass =3D 1,
+		.bInterfaceProtocol =3D 56, /* NOTE: This is the *slave* interface o=
f the CDC Union! */
+		.driver_info        =3D (unsigned long)&qmi_wwan_info,
+	},
 	{	/* Huawei E392, E398 and possibly others in "Windows mode"
 		 * using a combined control and data interface without any CDC
 		 * functional descriptors
--=20
1.7.10

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
