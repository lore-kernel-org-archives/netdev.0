From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: [PATCH 1/3] brcm80211: correct speed testing
Date: Mon,  2 May 2016 13:06:12 +0200
Message-ID: <1462187174-17180-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>, Oliver Neukum <ONeukum-IBi9RG/b67k@public.gmane.org>
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Allow for SS+ USB

Signed-off-by: Oliver Neukum <ONeukum-IBi9RG/b67k@public.gmane.org>
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c
index 869eb82..056bda3 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c
@@ -1368,7 +1368,9 @@ brcmf_usb_probe(struct usb_interface *intf, const struct usb_device_id *id)
 
 	devinfo->ifnum = desc->bInterfaceNumber;
 
-	if (usb->speed == USB_SPEED_SUPER)
+	if (usb->speed == USB_SPEED_SUPER_PLUS)
+		brcmf_dbg(USB, "Broadcom super speed plus USB WLAN interface detected\n");
+	else if (usb->speed == USB_SPEED_SUPER)
 		brcmf_dbg(USB, "Broadcom super speed USB WLAN interface detected\n");
 	else if (usb->speed == USB_SPEED_HIGH)
 		brcmf_dbg(USB, "Broadcom high speed USB WLAN interface detected\n");
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
