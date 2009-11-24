From: Oliver Neukum <oliver@neukum.org>
Subject: [patch]reset_resume for cdc-ether
Date: Tue, 24 Nov 2009 11:59:02 +0100
Message-ID: <200911241159.02098.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Brownell <david-b@pacbell.net>, netdev@vger.kernel.org,
	USB list <linux-usb@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:49736 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932208AbZKXK6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 05:58:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this is quite trivial but might be convenient to many users.

	Regards
		Oliver

Signed-off-by: Oliver Neukum <oliver@neukum.org>

--

commit 31deb426ccea8faf91f4373c1f12c98bb0d82c73
Author: Oliver Neukum <oliver@neukum.org>
Date:   Tue Nov 24 08:30:41 2009 +0100

    cdc-ether:imlement reset_resume()
    
    Normal resume can do double duty as reset_resume() for this driver

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index ed55024..11f73dd 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -617,6 +617,7 @@ static struct usb_driver cdc_driver = {
 	.disconnect =	usbnet_disconnect,
 	.suspend =	usbnet_suspend,
 	.resume =	usbnet_resume,
+	.reset_resume =	usbnet_resume,
 	.supports_autosuspend = 1,
 };
 
