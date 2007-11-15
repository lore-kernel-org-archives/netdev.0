From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] dm9601: Fix printk
Date: Thu, 15 Nov 2007 11:01:02 +0100
Message-ID: <E1Iu9pB-0002xZ-5J@nanv.dk>
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps.korsgaard.com ([64.79.194.204]:59338 "EHLO nanv.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753726AbXKSRPJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2007 12:15:09 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A printk in the error handling code of dm9601.c was missing a newline.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/usb/dm9601.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 2c68573..1ffdd10 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -94,7 +94,7 @@ static void dm_write_async_callback(struct urb *urb)
 	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;
 
 	if (urb->status < 0)
-		printk(KERN_DEBUG "dm_write_async_callback() failed with %d",
+		printk(KERN_DEBUG "dm_write_async_callback() failed with %d\n",
 		       urb->status);
 
 	kfree(req);
-- 
1.5.3.4

