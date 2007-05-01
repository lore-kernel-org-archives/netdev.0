From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw-mac80211: Add ID for ZyXEL AG-225H v2
Date: Tue,  1 May 2007 04:04:27 +0100 (BST)
Message-ID: <20070501030427.597847B409F@zog.reactivated.net>
Cc: netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:38815 "EHLO
	mtaout02-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754636AbXEADEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 23:04:31 -0400
Cc: linux-wireless@vger.kernel.org
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tested by davo on IRC
zd1211b chip 0586:3413 v4810 full 00-13-49 AL7230B_RF pa0 -----

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 drivers/net/wireless/mac80211/zd1211rw/zd_usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
index 35f4383..e623043 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
@@ -66,6 +66,7 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x0586, 0x3410), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0baf, 0x0121), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0586, 0x3412), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x0586, 0x3413), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0053, 0x5301), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
-- 
1.5.1.2

