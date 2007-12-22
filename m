From: Bjorge Dijkstra <bjd-a1rhEgazXTw@public.gmane.org>
Subject: [PATCH 1/8] Fix sparse warning: returning void-valued expression
Date: Sat, 22 Dec 2007 22:51:27 +0100
Message-ID: <11983602952341-git-send-email-bjd@jooz.net>
References: <11983602942818-git-send-email-bjd@jooz.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <11983602942818-git-send-email-bjd-a1rhEgazXTw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

rndis_unbind and usbnet_cdc_unbind don't return anything.

Signed-off-by: Bjorge Dijkstra <bjd-a1rhEgazXTw@public.gmane.org>
---
 drivers/net/usb/rndis_host.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index 1ebe325..96ef6a9 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -585,7 +585,7 @@ static void rndis_unbind(struct usbnet *dev, struct usb_interface *intf)
 		kfree(halt);
 	}
 
-	return usbnet_cdc_unbind(dev, intf);
+	usbnet_cdc_unbind(dev, intf);
 }
 
 /*
-- 
1.5.2.5
