From: maximilian attems <max-U9r9yeDMy7A@public.gmane.org>
Subject: [PATCH] hci_usb: Blacklist Bluetooth Dell Wireless 370 for SCO MTU
Date: Fri, 13 Jun 2008 13:47:19 +0200
Message-ID: <1213357639-1602-1-git-send-email-max@stro.at>
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mario Limonciello <Mario_Limonciello-8PEkshWhKlo@public.gmane.org>,
	Mario Limonciello <Mario_Limonciello-DYMqY+WieiM@public.gmane.org>,
	Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	maximilian attems <max-U9r9yeDMy7A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Mario Limonciello <Mario_Limonciello-8PEkshWhKlo@public.gmane.org>

Add Dell Wireless 370 device to blacklist to enable SCO MTU workaround.

fixes report
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/209715

Signed-off-by: Mario Limonciello <Mario_Limonciello-DYMqY+WieiM@public.gmane.org>
Signed-off-by: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: maximilian attems <max-U9r9yeDMy7A@public.gmane.org>
---
 drivers/bluetooth/hci_usb.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/bluetooth/hci_usb.c b/drivers/bluetooth/hci_usb.c
index d73e513..e9eef9a 100644
--- a/drivers/bluetooth/hci_usb.c
+++ b/drivers/bluetooth/hci_usb.c
@@ -134,6 +134,8 @@ static struct usb_device_id blacklist_ids[] = {
 
 	/* Dell laptop with Broadcom chip */
 	{ USB_DEVICE(0x413c, 0x8126), .driver_info = HCI_RESET | HCI_WRONG_SCO_MTU },
+	/* Dell Wireless 370 */
+	{ USB_DEVICE(0x413c, 0x8156), .driver_info = HCI_RESET | HCI_WRONG_SCO_MTU },
 
 	/* Microsoft Wireless Transceiver for Bluetooth 2.0 */
 	{ USB_DEVICE(0x045e, 0x009c), .driver_info = HCI_RESET },
-- 
1.5.5.3
