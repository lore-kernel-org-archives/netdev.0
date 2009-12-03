From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [patch]reset_resume for cdc-ether
Date: Thu, 3 Dec 2009 14:01:12 +0100
Message-ID: <200912031401.12703.oliver@neukum.org>
References: <20091202.221627.133392199.davem@davemloft.net> <200912031056.17103.oliver@neukum.org> <20091203.021456.40580217.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: david-b@pacbell.net, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:48526 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753688AbZLCNBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 08:01:07 -0500
In-Reply-To: <20091203.021456.40580217.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 3. Dezember 2009 11:14:56 schrieb David Miller:
> > Hi,
> > 
> > here's autosuspend again.
> 
> It doesn't apply to my tree still:
> 

Ok, this time against the correct tree comes reset_resume()

	Regards
		Oliver

Signed-off-by: Oliver Neukum <oliver@neukum.org>

--

commit a0516662d1d281c321410a8792603ba02c14293b
Author: Oliver Neukum <oliver@neukum.org>
Date:   Thu Dec 3 13:54:49 2009 +0100

    cdc-ether:imlement reset_resume()
    
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
 
 
