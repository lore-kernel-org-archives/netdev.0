From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] [USBNET] DM9501: Add Corega FEther USB-TXC support.
Date: Fri, 2 Mar 2007 18:41:18 -0800
Message-ID: <20070303024118.GA7637@kroah.com>
References: <20070301.164454.14331566.yoshfuji@linux-ipv6.org> <45E8D083.3010907@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38324 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992930AbXCCCm3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 21:42:29 -0500
Content-Disposition: inline
In-Reply-To: <45E8D083.3010907@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 02, 2007 at 08:33:55PM -0500, Jeff Garzik wrote:
> YOSHIFUJI Hideaki / ???????????? wrote:
> >Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> >---
> > drivers/usb/net/dm9601.c |    4 ++++
> > 1 files changed, 4 insertions(+), 0 deletions(-)
> >
> >diff --git a/drivers/usb/net/dm9601.c b/drivers/usb/net/dm9601.c
> >index 4a932e1..c0bc52b 100644
> >--- a/drivers/usb/net/dm9601.c
> >+++ b/drivers/usb/net/dm9601.c
> >@@ -571,6 +571,10 @@ static const struct driver_info dm9601_info = {
> > 
> > static const struct usb_device_id products[] = {
> > 	{
> >+	 USB_DEVICE(0x07aa, 0x9601),	/* Corega FEther USB-TXC */
> >+	 .driver_info = (unsigned long)&dm9601_info,
> >+	 },
> >+	{
> 
> 
> ACK the patch, though I wonder if this shouldn't instead go to Greg.
> 
> Honestly, I would prefer that the USB net drivers were moved into 
> drivers/net with the other net drivers, /then/ I would merge such 
> patches.  We don't add drivers for PCI-based hardware to 
> drivers/pci/net, after all...

I have no objection to that.  Things have been moving out of the
drivers/usb/ directory over time, and if you want to take these under
your umbrella too, that's fine with me.

David, any objections?

thanks,

greg k-h
