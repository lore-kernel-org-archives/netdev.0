From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] isdn: hfcsusb: constify usb_device_id
Date: Tue,  8 Aug 2017 22:19:28 +0530
Message-ID: <9bd81b17bb29dfe9ca3735b1a6b3a9937a336a9f.1502210665.git.arvind.yadav.cs@gmail.com>
References: <fb99bdbed78f5948e9ebb99365d002d41c8437ec.1502210664.git.arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fb99bdbed78f5948e9ebb99365d002d41c8437ec.1502210664.git.arvind.yadav.cs@gmail.com>
In-Reply-To: <fb99bdbed78f5948e9ebb99365d002d41c8437ec.1502210664.git.arvind.yadav.cs@gmail.com>
References: <fb99bdbed78f5948e9ebb99365d002d41c8437ec.1502210664.git.arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/isdn/hardware/mISDN/hfcsusb.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.h b/drivers/isdn/hardware/mISDN/hfcsusb.h
index 4157311..5f8f1d9 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.h
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.h
@@ -337,7 +337,7 @@ static const char *HFC_NT_LAYER1_STATES[HFC_MAX_NT_LAYER1_STATE + 1] = {
 };
 
 /* supported devices */
-static struct usb_device_id hfcsusb_idtab[] = {
+static const struct usb_device_id hfcsusb_idtab[] = {
 	{
 		USB_DEVICE(0x0959, 0x2bd0),
 		.driver_info = (unsigned long) &((struct hfcsusb_vdata)
-- 
2.7.4
