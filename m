From: Oliver Neukum <oliver@neukum.org>
Subject: [PATCH 01/02]cdc-ether:Implement reset_resume()
Date: Thu, 3 Dec 2009 22:10:08 +0100
Message-ID: <200912032210.08362.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:53097 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbZLCVJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:09:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit b215603d7bbe3907666d27ebcd6ae847dd4f3a03
Author: Oliver Neukum <oliver@neukum.org>
Date:   Thu Dec 3 22:02:11 2009 +0100

    cdc-ether:Implement reset_resume()
    
    Normal resume can do double duty as reset_resume() for this driver
    as it keeps no state in the device
    
    Signed-off-by: Oliver Neukum <oliver@neukum.org>

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
 
 
