From: Bjorn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH 1/3] option: Removing one bogus and adding some new Huawei combinations
Date: Tue, 13 Dec 2011 05:33:02 +0100
Message-ID: <1323750784-32608-2-git-send-email-bjorn@mork.no>
References: <1323750784-32608-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1323750784-32608-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Huawei use the product code HUAWEI_PRODUCT_E353 (0x1506) for a
number of different devices, which each can appear with a number
of different descriptor sets.  Different types of interfaces
can be identified by looking at the subclass and protocol fields

Subclass 1 protocol 8 is actually the data interface of a CDC
ECM set, with subclass 1 protocol 9 as the control interface.
Neither support serial data communcation, and cannot therefore
be supported by this driver.

At the same time, add a few other sets which appear if the
device is configured in "Windows mode" using this modeswitch
message:
55534243000000000000000000000011060000000100000000000000000000

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/usb/serial/option.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/usb/serial/option.c b/drivers/usb/serial/option.c
index e342660..c90f5a4 100644
--- a/drivers/usb/serial/option.c
+++ b/drivers/usb/serial/option.c
@@ -663,7 +663,9 @@ static const struct usb_device_id option_ids[] =3D =
{
 	{ USB_DEVICE_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, HUAWEI_PRODUCT_E353=
, 0xff, 0x01, 0x01) },
 	{ USB_DEVICE_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, HUAWEI_PRODUCT_E353=
, 0xff, 0x01, 0x02) },
 	{ USB_DEVICE_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, HUAWEI_PRODUCT_E353=
, 0xff, 0x01, 0x03) },
-	{ USB_DEVICE_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, HUAWEI_PRODUCT_E353=
, 0xff, 0x01, 0x08) },
+	{ USB_DEVICE_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, HUAWEI_PRODUCT_E353=
, 0xff, 0x01, 0x10) },
+	{ USB_DEVICE_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, HUAWEI_PRODUCT_E353=
, 0xff, 0x01, 0x12) },
+	{ USB_DEVICE_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, HUAWEI_PRODUCT_E353=
, 0xff, 0x01, 0x13) },
 	{ USB_DEVICE(NOVATELWIRELESS_VENDOR_ID, NOVATELWIRELESS_PRODUCT_V640)=
 },
 	{ USB_DEVICE(NOVATELWIRELESS_VENDOR_ID, NOVATELWIRELESS_PRODUCT_V620)=
 },
 	{ USB_DEVICE(NOVATELWIRELESS_VENDOR_ID, NOVATELWIRELESS_PRODUCT_V740)=
 },
--=20
1.7.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
