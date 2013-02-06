From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH] net: qmi_wwan: add more Huawei devices, including E320
Date: Wed,  6 Feb 2013 16:22:08 +0100
Message-ID: <1360164128-27076-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Adding new class/subclass/protocol combinations based on the GPLed
out-of-tree Huawei driver. One of these has already appeared on a
device labelled as "E320".

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/qmi_wwan.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 2ca7f8e..c8e05e2 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -351,6 +351,10 @@ static const struct usb_device_id products[] =3D {
 		USB_VENDOR_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, USB_CLASS_VENDOR_SPE=
C, 1, 57),
 		.driver_info        =3D (unsigned long)&qmi_wwan_info,
 	},
+	{	/* HUAWEI_INTERFACE_NDIS_CONTROL_QUALCOMM */
+		USB_VENDOR_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, USB_CLASS_VENDOR_SPE=
C, 0x01, 0x69),
+		.driver_info        =3D (unsigned long)&qmi_wwan_info,
+	},
=20
 	/* 2. Combined interface devices matching on class+protocol */
 	{	/* Huawei E367 and possibly others in "Windows mode" */
@@ -361,6 +365,14 @@ static const struct usb_device_id products[] =3D {
 		USB_VENDOR_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, USB_CLASS_VENDOR_SPE=
C, 1, 17),
 		.driver_info        =3D (unsigned long)&qmi_wwan_info,
 	},
+	{	/* HUAWEI_NDIS_SINGLE_INTERFACE_VDF */
+		USB_VENDOR_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, USB_CLASS_VENDOR_SPE=
C, 0x01, 0x37),
+		.driver_info        =3D (unsigned long)&qmi_wwan_info,
+	},
+	{	/* HUAWEI_INTERFACE_NDIS_HW_QUALCOMM */
+		USB_VENDOR_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, USB_CLASS_VENDOR_SPE=
C, 0x01, 0x67),
+		.driver_info        =3D (unsigned long)&qmi_wwan_info,
+	},
 	{	/* Pantech UML290, P4200 and more */
 		USB_VENDOR_AND_INTERFACE_INFO(0x106c, USB_CLASS_VENDOR_SPEC, 0xf0, 0=
xff),
 		.driver_info        =3D (unsigned long)&qmi_wwan_info,
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
