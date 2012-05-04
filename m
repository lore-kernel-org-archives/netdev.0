From: Xose Vazquez Perez <xose.vazquez@gmail.com>
Subject: [PATCH] irda: irda-usb.c URL to sigmatel stir 4210/4220/4116 fw from archive.org
Date: Fri,  4 May 2012 23:37:57 +0200
Message-ID: <1336167477-28835-1-git-send-email-xose.vazquez@gmail.com>
To: xose.vazquez@gmail.com, samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sigmatel was bought by Freescale, the web is dead and the firmware was lost.

Signed-off-by: Xose Vazquez Perez <xose.vazquez@gmail.com>
---
 drivers/net/irda/irda-usb.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 72f687b..0c929f2 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -1081,6 +1081,7 @@ static int stir421x_patch_device(struct irda_usb_cb *self)
         /*
          * Known firmware patch file names for STIR421x dongles
          * are "42101001.sb" or "42101002.sb"
+         * http://web.archive.org/web/http://www.sigmatel.com/documents/stir4210_4220_4116_patch_files.tar.gz
          */
         sprintf(stir421x_fw_name, "4210%4X.sb",
                 self->usbdev->descriptor.bcdDevice);
-- 
1.7.10.1
