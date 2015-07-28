From: Shraddha Barke <shraddha.6596@gmail.com>
Subject: [PATCH] Drivers: isdn: Drop unnecessary continue
Date: Tue, 28 Jul 2015 12:46:06 +0530
Message-ID: <1438067766-6438-1-git-send-email-shraddha.6596@gmail.com>
Cc: Shraddha Barke <shraddha.6596@gmail.com>
To: Karsten Keil <isdn@linux-pingi.de>,
	Julia Lawall <julia.lawall@lip6.fr>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The semantic patch used to make this change is :

@@
@@
for (...;...;...) {
  ...
  if (...) {
    ...
-   continue;
  }
}

Signed-off-by: Shraddha Barke <shraddha.6596@gmail.com>
---
 drivers/isdn/hardware/mISDN/hfcsusb.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index 114f3bc..34e4b6c 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -1923,7 +1923,6 @@ hfcsusb_probe(struct usb_interface *intf, const struct usb_device_id *id)
 		    (le16_to_cpu(dev->descriptor.idProduct)
 		     == hfcsusb_idtab[i].idProduct)) {
 			vend_idx = i;
-			continue;
 		}
 	}
 
-- 
2.1.0
