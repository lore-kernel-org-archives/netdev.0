From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Add ID for Senao NUB-8301
Date: Sat, 12 Aug 2006 17:59:50 +0100 (BST)
Message-ID: <20060812165950.1859B8E776E@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:56521 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932567AbWHLQ7r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 12:59:47 -0400
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tested by lyakh on IRC

zd1211 chip 1740:2000 v4721 high 00-02-6f AL7230B_RF pa0 g---

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_usb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/zd_usb.c b/zd_usb.c
index 044f209..5284357 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -40,6 +40,7 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x0df6, 0x9071), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x157e, 0x300b), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x079b, 0x004a), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x1740, 0x2000), .driver_info = DEVICE_ZD1211 },
 	/* ZD1211B */
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
-- 
1.4.1.1

