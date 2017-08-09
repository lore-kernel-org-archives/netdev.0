From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v2 18/20] rtl8192cu: constify usb_device_id
Date: Wed,  9 Aug 2017 22:01:05 +0530
Message-ID: <1502296265-21726-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: kvalo@codeaurora.org, Larry.Finger@lwfinger.net,
        chaoming_li@realsil.com.cn
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
changes in v2:
              Re-submitting wireless separately.

 drivers/net/wireless/realtek/rtlwifi/rtl8192cu/sw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/sw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/sw.c
index 96c923b..e673bc2 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/sw.c
@@ -275,7 +275,7 @@ static struct rtl_hal_cfg rtl92cu_hal_cfg = {
 #define USB_VENDER_ID_REALTEK		0x0bda
 
 /* 2010-10-19 DID_USB_V3.4 */
-static struct usb_device_id rtl8192c_usb_ids[] = {
+static const struct usb_device_id rtl8192c_usb_ids[] = {
 
 	/*=== Realtek demoboard ===*/
 	/* Default ID */
-- 
2.7.4
