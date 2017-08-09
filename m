From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v2 13/20] rt2500usb: constify usb_device_id
Date: Wed,  9 Aug 2017 21:59:14 +0530
Message-ID: <1502296155-21470-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: kvalo@codeaurora.org, sgruszka@redhat.com,
        helmut.schaa@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:32787 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752630AbdHIQ3Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 12:29:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

usb_device_id are not supposed to change at runtime. All functions
working with usb_device_id provided by <linux/usb.h> work with
const usb_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
changes in v2:
              Re-submitting wireless separately.

 drivers/net/wireless/ralink/rt2x00/rt2500usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ralink/rt2x00/rt2500usb.c b/drivers/net/wireless/ralink/rt2x00/rt2500usb.c
index 529e059..f4b48b7 100644
--- a/drivers/net/wireless/ralink/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/ralink/rt2x00/rt2500usb.c
@@ -1911,7 +1911,7 @@ static const struct rt2x00_ops rt2500usb_ops = {
 /*
  * rt2500usb module information.
  */
-static struct usb_device_id rt2500usb_device_table[] = {
+static const struct usb_device_id rt2500usb_device_table[] = {
 	/* ASUS */
 	{ USB_DEVICE(0x0b05, 0x1706) },
 	{ USB_DEVICE(0x0b05, 0x1707) },
-- 
2.7.4
