From: Oliver Neukum <oliver@neukum.org>
Subject: [PATCH] usbnet: drop unneeded check for NULL
Date: Tue,  4 Sep 2012 16:21:54 +0200
Message-ID: <1346768514-19823-1-git-send-email-oliver@neukum.org>
Cc: Oliver Neukum <oliver@neukum.org>, Oliver Neukum <oneukum@suse.de>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:36747 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757201Ab2IDOaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 10:30:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

usbnet_start_xmit() is always called with a valid skb

Signed-off-by: Oliver Neukum <oneukum@suse.de>
---
 drivers/net/usb/usbnet.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 8531c1c..5234d20 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1092,8 +1092,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	unsigned long		flags;
 	int retval;
 
-	if (skb)
-		skb_tx_timestamp(skb);
+	skb_tx_timestamp(skb);
 
 	// some devices want funky USB-level framing, for
 	// win32 driver (usually) and/or hardware quirks
-- 
1.7.7
