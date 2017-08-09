From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v2 14/20] rt2800usb: constify usb_device_id
Date: Wed,  9 Aug 2017 21:59:15 +0530
Message-ID: <1502296155-21470-2-git-send-email-arvind.yadav.cs@gmail.com>
References: <1502296155-21470-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: kvalo@codeaurora.org, sgruszka@redhat.com,
        helmut.schaa@googlemail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502296155-21470-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
changes in v2:
              Re-submitting wireless separately.

 drivers/net/wireless/ralink/rt2x00/rt2800usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ralink/rt2x00/rt2800usb.c b/drivers/net/wireless/ralink/rt2x00/rt2800usb.c
index 685b8e0..cd9547e 100644
--- a/drivers/net/wireless/ralink/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/ralink/rt2x00/rt2800usb.c
@@ -915,7 +915,7 @@ static const struct rt2x00_ops rt2800usb_ops = {
 /*
  * rt2800usb module information.
  */
-static struct usb_device_id rt2800usb_device_table[] = {
+static const struct usb_device_id rt2800usb_device_table[] = {
 	/* Abocom */
 	{ USB_DEVICE(0x07b8, 0x2870) },
 	{ USB_DEVICE(0x07b8, 0x2770) },
-- 
2.7.4
