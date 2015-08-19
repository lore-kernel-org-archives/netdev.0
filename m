From: Adrien Schildknecht <adrien+dev@schischi.me>
Subject: [PATCH] rtlwifi: rtl8192cu: Add new device ID
Date: Wed, 19 Aug 2015 15:51:31 +0200
Message-ID: <1439992291-24912-1-git-send-email-adrien+dev@schischi.me>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Adrien Schildknecht <adrien+dev@schischi.me>
To: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
	kvalo@codeaurora.org, linville@tuxdriver.com, marex@denx.de,
	fzuuzf@googlemail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The v2 of NetGear WNA1000M uses a different idProduct: USB ID 0846:9043

Signed-off-by: Adrien Schildknecht <adrien+dev@schischi.me>
---
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
index 23806c2..8b4238a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -321,6 +321,7 @@ static struct usb_device_id rtl8192c_usb_ids[] = {
 	{RTL_USB_DEVICE(0x07b8, 0x8188, rtl92cu_hal_cfg)}, /*Abocom - Abocom*/
 	{RTL_USB_DEVICE(0x07b8, 0x8189, rtl92cu_hal_cfg)}, /*Funai - Abocom*/
 	{RTL_USB_DEVICE(0x0846, 0x9041, rtl92cu_hal_cfg)}, /*NetGear WNA1000M*/
+	{RTL_USB_DEVICE(0x0846, 0x9043, rtl92cu_hal_cfg)}, /*NetGear WNA1000Mv2*/
 	{RTL_USB_DEVICE(0x0b05, 0x17ba, rtl92cu_hal_cfg)}, /*ASUS-Edimax*/
 	{RTL_USB_DEVICE(0x0bda, 0x5088, rtl92cu_hal_cfg)}, /*Thinkware-CC&C*/
 	{RTL_USB_DEVICE(0x0df6, 0x0052, rtl92cu_hal_cfg)}, /*Sitecom - Edimax*/
-- 
2.5.0
