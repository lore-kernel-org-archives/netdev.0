From: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
Subject: [PATCH] net: qmi_wwan: add additional Sierra Wireless QMI devices
Date: Thu, 29 May 2014 13:44:45 +0200
Message-ID: <1401363885-6846-1-git-send-email-aleksander@aleksander.es>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

A set of new VID/PIDs retrieved from the out-of-tree GobiNet/GobiSerial
Sierra Wireless drivers.

Signed-off-by: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
---

Hey,

The patch should be applied after the following one:
  [PATCH] net: qmi_wwan: add Netgear AirCard 341U
  http://marc.info/?l=linux-netdev&m=140130407711048&w=2

Cheers!

 drivers/net/usb/qmi_wwan.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index c0b611f..faa1277 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -753,7 +753,11 @@ static const struct usb_device_id products[] = {
 	{QMI_FIXED_INTF(0x1199, 0x901f, 8)},    /* Sierra Wireless EM7355 */
 	{QMI_FIXED_INTF(0x1199, 0x9041, 8)},	/* Sierra Wireless MC7305/MC7355 */
 	{QMI_FIXED_INTF(0x1199, 0x9051, 8)},	/* Netgear AirCard 340U */
+	{QMI_FIXED_INTF(0x1199, 0x9053, 8)},	/* Sierra Wireless Modem */
+	{QMI_FIXED_INTF(0x1199, 0x9054, 8)},	/* Sierra Wireless Modem */
 	{QMI_FIXED_INTF(0x1199, 0x9055, 8)},	/* Netgear AirCard 341U */
+	{QMI_FIXED_INTF(0x1199, 0x9056, 8)},	/* Sierra Wireless Modem */
+	{QMI_FIXED_INTF(0x1199, 0x9061, 8)},	/* Sierra Wireless Modem */
 	{QMI_FIXED_INTF(0x1bbb, 0x011e, 4)},	/* Telekom Speedstick LTE II (Alcatel One Touch L100V LTE) */
 	{QMI_FIXED_INTF(0x1bbb, 0x0203, 2)},	/* Alcatel L800MA */
 	{QMI_FIXED_INTF(0x2357, 0x0201, 4)},	/* TP-LINK HSUPA Modem MA180 */
--
1.9.3
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
