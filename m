From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net] r8152: add terminating newline
Date: Mon, 6 Jan 2014 17:19:59 +0800
Message-ID: <1388999999-9218-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The netif_err() and netif_info() should have the terminating newline
at the end of the message.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 5107372..3d8a565 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2135,11 +2135,11 @@ static int rtl8152_probe(struct usb_interface *intf,
 
 	ret = register_netdev(netdev);
 	if (ret != 0) {
-		netif_err(tp, probe, netdev, "couldn't register the device");
+		netif_err(tp, probe, netdev, "couldn't register the device\n");
 		goto out1;
 	}
 
-	netif_info(tp, probe, netdev, "%s", DRIVER_VERSION);
+	netif_info(tp, probe, netdev, "%s\n", DRIVER_VERSION);
 
 	return 0;
 
-- 
1.8.4.2

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
