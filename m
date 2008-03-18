From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] dm9601: configure MAC to drop invalid (crc/length) packets
Date: Tue, 18 Mar 2008 23:16:54 +0100
Message-ID: <1205878614-29065-3-git-send-email-jacmet@sunsite.dk>
References: <1205878614-29065-1-git-send-email-jacmet@sunsite.dk>
 <1205878614-29065-2-git-send-email-jacmet@sunsite.dk>
Cc: Peter Korsgaard <jacmet@sunsite.dk>
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:9981 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934317AbYCSUhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 16:37:40 -0400
Received: by fg-out-1718.google.com with SMTP id l27so541332fgb.17
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 13:37:36 -0700 (PDT)
In-Reply-To: <1205878614-29065-2-git-send-email-jacmet@sunsite.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/usb/dm9601.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 1821778..824dbc6 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -341,7 +341,7 @@ static void dm9601_set_multicast(struct net_device *net)
 	/* We use the 20 byte dev->data for our 8 byte filter buffer
 	 * to avoid allocating memory that is tricky to free later */
 	u8 *hashes = (u8 *) & dev->data;
-	u8 rx_ctl = 0x01;
+	u8 rx_ctl = 0x31;
 
 	memset(hashes, 0x00, DM_MCAST_SIZE);
 	hashes[DM_MCAST_SIZE - 1] |= 0x80;	/* broadcast address */
-- 
1.5.4.1

