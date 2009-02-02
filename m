From: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] hso: add new device id's
Date: Mon, 02 Feb 2009 15:59:05 +0100
Message-ID: <49870A39.8000806@option.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050709090004030109090804"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050709090004030109090804
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds a few device id's and removes one which will never be used.

Signed-off-by: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
---



--------------050709090004030109090804
Content-Type: text/x-patch;
 name="hso_add_device_ids.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_add_device_ids.patch"

This patch adds a few device id's and removes one which will never be used.

Signed-off-by: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
---
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 0d0fa91..fe98aca 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -455,6 +455,7 @@ static const struct usb_device_id hso_ids[] = {
 	{icon321_port_device(0x0af0, 0xd033)},	/* Icon-322 */
 	{USB_DEVICE(0x0af0, 0x7301)},		/* GE40x */
 	{USB_DEVICE(0x0af0, 0x7361)},		/* GE40x */
+	{USB_DEVICE(0x0af0, 0x7381)},		/* GE40x */
 	{USB_DEVICE(0x0af0, 0x7401)},		/* GI 0401 */
 	{USB_DEVICE(0x0af0, 0x7501)},		/* GTM 382 */
 	{USB_DEVICE(0x0af0, 0x7601)},		/* GE40x */
@@ -462,7 +463,8 @@ static const struct usb_device_id hso_ids[] = {
 	{USB_DEVICE(0x0af0, 0x7801)},
 	{USB_DEVICE(0x0af0, 0x7901)},
 	{USB_DEVICE(0x0af0, 0x7361)},
-	{icon321_port_device(0x0af0, 0xd051)},
+	{USB_DEVICE(0x0af0, 0xd057)},
+	{USB_DEVICE(0x0af0, 0xd055)},
 	{}
 };
 MODULE_DEVICE_TABLE(usb, hso_ids);

--------------050709090004030109090804--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
