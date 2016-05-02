From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: [PATCH 2/3] usbnet: correct speed testing
Date: Mon,  2 May 2016 13:06:13 +0200
Message-ID: <1462187174-17180-2-git-send-email-oneukum@suse.com>
References: <1462187174-17180-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>, Oliver Neukum <ONeukum-IBi9RG/b67k@public.gmane.org>
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1462187174-17180-1-git-send-email-oneukum-IBi9RG/b67k@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Allow for SS+ USB

Signed-off-by: Oliver Neukum <ONeukum-IBi9RG/b67k@public.gmane.org>
---
 drivers/net/usb/usbnet.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 4f08426..bc46ef9 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -355,6 +355,7 @@ void usbnet_update_max_qlen(struct usbnet *dev)
 		dev->tx_qlen = MAX_QUEUE_MEMORY / dev->hard_mtu;
 		break;
 	case USB_SPEED_SUPER:
+	case USB_SPEED_SUPER_PLUS:
 		/*
 		 * Not take default 5ms qlen for super speed HC to
 		 * save memory, and iperf tests show 2.5ms qlen can
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
