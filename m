From: Patrik Halfar <patrik_halfar-1nzAiFnr9bbtwjQa/ONI9g@public.gmane.org>
Subject: [PATCH] Add Dell Wireless 5809e Gobi 4G HSPA+ Mobile Broadband Card (rev3) to qmi_wwan
Date: Sat, 20 Feb 2016 18:49:40 +0100
Message-ID: <1455990580-23962-1-git-send-email-patrik_halfar@halfarit.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrik Halfar <patrik_halfar-1nzAiFnr9bbtwjQa/ONI9g@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

New revison of Dell Wireless 5809e Gobi 4G HSPA+ Mobile Broadband Card =
has new idProduct

Bus 002 Device 006: ID 413c:81b3 Dell Computer Corp.
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               2.00
  bDeviceClass            0
  bDeviceSubClass         0
  bDeviceProtocol         0
  bMaxPacketSize0        64
  idVendor           0x413c Dell Computer Corp.
  idProduct          0x81b3
  bcdDevice            0.06
  iManufacturer           1 Sierra Wireless, Incorporated
  iProduct                2 Dell Wireless 5809e Gobi=E2=84=A2 4G HSPA+ =
Mobile Broadband Card
  iSerial                 3
  bNumConfigurations      2

Signed-off-by: Patrik Halfar <patrik_halfar-1nzAiFnr9bbtwjQa/ONI9g@public.gmane.org>
---
 drivers/net/usb/qmi_wwan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 23e9880791fc..5ef413305895 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -884,6 +884,7 @@ static const struct usb_device_id products[] =3D {
 	{QMI_FIXED_INTF(0x413c, 0x81a8, 8)},	/* Dell Wireless 5808 Gobi(TM) 4=
G LTE Mobile Broadband Card */
 	{QMI_FIXED_INTF(0x413c, 0x81a9, 8)},	/* Dell Wireless 5808e Gobi(TM) =
4G LTE Mobile Broadband Card */
 	{QMI_FIXED_INTF(0x413c, 0x81b1, 8)},	/* Dell Wireless 5809e Gobi(TM) =
4G LTE Mobile Broadband Card */
+	{QMI_FIXED_INTF(0x413c, 0x81b3, 8)},	/* Dell Wireless 5809e Gobi(TM) =
4G LTE Mobile Broadband Card (rev3) */
 	{QMI_FIXED_INTF(0x03f0, 0x4e1d, 8)},	/* HP lt4111 LTE/EV-DO/HSPA+ Gob=
i 4G Module */
 	{QMI_FIXED_INTF(0x22de, 0x9061, 3)},	/* WeTelecom WPD-600N */
 	{QMI_FIXED_INTF(0x1e0e, 0x9001, 5)},	/* SIMCom 7230E */
--=20
2.4.10

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
