From: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2] hso: add new device id's
Date: Tue, 03 Feb 2009 11:39:43 +0100
Message-ID: <49881EEF.4060705@option.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000000020103040006060402"
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000000020103040006060402
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds a few device ID's. It also removes an ID that was used 
in an internal engineering version of a device and will never see 
commercial light. Even if this ID will be 'recycled' in the future, 
which is very unlikely, we don't know what kind of device will be behind 
it. Therefore it's safer to remove it.

Signed-off-by: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
---

--------------000000020103040006060402
Content-Type: text/x-patch;
 name="hso_add_device_ids.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_add_device_ids.patch"

This patch adds a few device id's. It also removes an ID that was used in an internal engineering version of a device and will never see commercial light. Even if this ID will be 'recycled' in the future, which is very unlikely, I don't know what kind of device will be behind it. Therefore it's safer to remove it.

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

--------------000000020103040006060402--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
