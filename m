From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 21/35] wireless: broadcom: brcm80211: constify usb_device_id
Date: Tue,  8 Aug 2017 21:31:26 +0530
Message-ID: <1502208086-11916-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, brcm80211-dev-list@cypress.com
To: kvalo@codeaurora.org, petkan@nucleusys.com,
        arend.vanspriel@broadcom.com, franky.lin@broadcom.com,
        wright.feng@cypress.com, hante.meuleman@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c
index 0eea48e..51562b0 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c
@@ -1463,7 +1463,7 @@ static int brcmf_usb_reset_resume(struct usb_interface *intf)
 #define LINKSYS_USB_DEVICE(dev_id)	\
 	{ USB_DEVICE(BRCM_USB_VENDOR_ID_LINKSYS, dev_id) }
 
-static struct usb_device_id brcmf_usb_devid_table[] = {
+static const struct usb_device_id brcmf_usb_devid_table[] = {
 	BRCMF_USB_DEVICE(BRCM_USB_43143_DEVICE_ID),
 	BRCMF_USB_DEVICE(BRCM_USB_43236_DEVICE_ID),
 	BRCMF_USB_DEVICE(BRCM_USB_43242_DEVICE_ID),
-- 
2.7.4
