From: Anthony Wong <anthony.wong@ubuntu.com>
Subject: [PATCH] rt2x00: add new rt2800usb device Buffalo WLI-UC-G450
Date: Tue, 23 Feb 2016 23:09:22 +0800
Message-ID: <1456240162-24118-1-git-send-email-anthony.wong@ubuntu.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add USB ID 0411:01fd for Buffalo WLI-UC-G450 wireless adapter,
RT chipset 3593

Signed-off-by: Anthony Wong <anthony.wong@ubuntu.com>
Cc: stable@vger.kernel.org
---
 drivers/net/wireless/ralink/rt2x00/rt2800usb.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/ralink/rt2x00/rt2800usb.c b/drivers/net/wireless/ralink/rt2x00/rt2800usb.c
index bf9afbf..4b0bb6b 100644
--- a/drivers/net/wireless/ralink/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/ralink/rt2x00/rt2800usb.c
@@ -1026,6 +1026,7 @@ static struct usb_device_id rt2800usb_device_table[] = {
 	{ USB_DEVICE(0x0411, 0x01a2) },
 	{ USB_DEVICE(0x0411, 0x01ee) },
 	{ USB_DEVICE(0x0411, 0x01a8) },
+	{ USB_DEVICE(0x0411, 0x01fd) },
 	/* Corega */
 	{ USB_DEVICE(0x07aa, 0x002f) },
 	{ USB_DEVICE(0x07aa, 0x003c) },
-- 
2.5.0
