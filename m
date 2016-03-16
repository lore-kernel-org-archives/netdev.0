From: Patrik Halfar <patrik_halfar@halfarit.cz>
Subject: [PATCH] USB: qmi_wwan: add Dell Wireless 5809e Gobi 4G HSPA+ (rev3)
Date: Wed, 16 Mar 2016 12:13:45 +0100
Message-ID: <1458126825-15753-1-git-send-email-patrik_halfar@halfarit.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrik Halfar <patrik_halfar@halfarit.cz>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tartaros.halfarit.cz ([185.62.108.38]:43224 "EHLO
	tartaros.halfarit.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934141AbcCPLOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 07:14:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Signed-off-by: Patrik Halfar <patrik_halfar@halfarit.cz>
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
