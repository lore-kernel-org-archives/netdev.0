From: Oliver Neukum <oliver@neukum.org>
Subject: [PATCH 1/2]cdc-ether:Implement reset_resume()
Date: Thu, 3 Dec 2009 22:41:07 +0100
Message-ID: <200912032241.07433.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:51976 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752601AbZLCVk4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:40:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From b215603d7bbe3907666d27ebcd6ae847dd4f3a03 Mon Sep 17 00:00:00 2001
From: Oliver Neukum <oliver@neukum.org>
Date: Thu, 3 Dec 2009 22:02:11 +0100
Subject: [PATCH 1/2] cdc-ether:Implement reset_resume()

Normal resume can do double duty as reset_resume() for this driver
as it keeps no state in the device

Signed-off-by: Oliver Neukum <oliver@neukum.org>
---
 drivers/net/usb/cdc_ether.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 21e1ba1..075e33f 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -610,6 +610,7 @@ static struct usb_driver cdc_driver = {
 	.disconnect =	usbnet_disconnect,
 	.suspend =	usbnet_suspend,
 	.resume =	usbnet_resume,
+	.reset_resume =	usbnet_resume,
 };
 
 
-- 
1.6.4.2

