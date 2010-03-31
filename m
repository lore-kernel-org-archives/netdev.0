From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv3] drivers/net/usb: Add new driver ipheth
Date: Thu, 01 Apr 2010 00:28:30 +0100
Message-ID: <1270078110.8653.493.camel@localhost>
References: <1269984864-28159-1-git-send-email-agimenez@sysvalve.es>
	 <1270064527-8485-1-git-send-email-agimenez@sysvalve.es>
	 <1270077538.8653.484.camel@localhost>  <20100331232516.GA27730@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "L. Alberto Gim?nez" <agimenez@sysvalve.es>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, oliver@neukum.org,
	linville@tuxdriver.com, j.dumon@option.com,
	steve.glendinning@smsc.com, davem@davemloft.net, dgiagio@gmail.com,
	dborca@yahoo.com
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:50870 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758269Ab0CaX2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 19:28:36 -0400
In-Reply-To: <20100331232516.GA27730@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-31 at 16:25 -0700, Greg KH wrote:
> On Thu, Apr 01, 2010 at 12:18:58AM +0100, Ben Hutchings wrote:
> > On Wed, 2010-03-31 at 21:42 +0200, L. Alberto Gim??nez wrote:
[...]
> > > +#include <linux/usb.h>
> > > +#include <linux/workqueue.h>
> > > +
> > > +#define USB_VENDOR_APPLE        0x05ac
> > > +#define USB_PRODUCT_IPHETH     0x1290
> > > +#define USB_PRODUCT_IPHETH_3G   0x1292
> > > +#define USB_PRODUCT_IPHETH_3GS  0x1294
> > 
> > Apple doesn't assign device ids to ipheth so either the names are
> > incorrect or you should get proper device ids.  I believe the Linux
> > Foundation has a USB vendor id and could assign device ids under that.
> 
> You mean there is an application on the iphone that sets the device id
> here?  I thought this was the iphone device ids already assigned to
> apple.
[...]

That's why my first suggestion was that the names are incorrect; they
should probably include IPHONE not IPHETH.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

