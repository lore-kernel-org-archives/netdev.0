From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH 1/2] dm9601: trivial comment fixes
Date: Wed, 13 May 2009 22:09:53 +0200
Message-ID: <1242245393-14973-1-git-send-email-jacmet@sunsite.dk>
Cc: Peter Korsgaard <jacmet@sunsite.dk>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:43534 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbZEMUJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 16:09:55 -0400
Received: by ewy24 with SMTP id 24so1078528ewy.37
        for <netdev@vger.kernel.org>; Wed, 13 May 2009 13:09:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The comments describing the rx/tx headers used a combination of zero-
and 1-based indexing, leading to confusion. 

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/usb/dm9601.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 6fc4f82..7ae8244 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -497,10 +497,10 @@ static int dm9601_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	int len;
 
 	/* format:
-	   b0: rx status
-	   b1: packet length (incl crc) low
-	   b2: packet length (incl crc) high
-	   b3..n-4: packet data
+	   b1: rx status
+	   b2: packet length (incl crc) low
+	   b3: packet length (incl crc) high
+	   b4..n-4: packet data
 	   bn-3..bn: ethernet crc
 	 */
 
@@ -533,8 +533,8 @@ static struct sk_buff *dm9601_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 	int len;
 
 	/* format:
-	   b0: packet length low
-	   b1: packet length high
+	   b1: packet length low
+	   b2: packet length high
 	   b3..n: packet data
 	*/
 
-- 
1.6.2

