From: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
Subject: [PATCH] net: qmi_wwan: interface #11 in Sierra Wireless MC73xx is not QMI
Date: Thu, 29 May 2014 13:51:36 +0200
Message-ID: <1401364296-7207-1-git-send-email-aleksander@aleksander.es>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This interface is unusable, as the cdc-wdm character device doesn't reply to
any QMI command. Also, the out-of-tree Sierra Wireless GobiNet driver fully
skips it.

Signed-off-by: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
---
 drivers/net/usb/qmi_wwan.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index faa1277..dc4bf06 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -748,7 +748,6 @@ static const struct usb_device_id products[] = {
 	{QMI_FIXED_INTF(0x1199, 0x68a2, 19)},	/* Sierra Wireless MC7710 in QMI mode */
 	{QMI_FIXED_INTF(0x1199, 0x68c0, 8)},	/* Sierra Wireless MC73xx */
 	{QMI_FIXED_INTF(0x1199, 0x68c0, 10)},	/* Sierra Wireless MC73xx */
-	{QMI_FIXED_INTF(0x1199, 0x68c0, 11)},	/* Sierra Wireless MC73xx */
 	{QMI_FIXED_INTF(0x1199, 0x901c, 8)},    /* Sierra Wireless EM7700 */
 	{QMI_FIXED_INTF(0x1199, 0x901f, 8)},    /* Sierra Wireless EM7355 */
 	{QMI_FIXED_INTF(0x1199, 0x9041, 8)},	/* Sierra Wireless MC7305/MC7355 */
-- 
1.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
