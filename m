From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCHv3] drivers/net/usb: Add new driver ipheth
Date: Wed, 31 Mar 2010 16:25:16 -0700
Message-ID: <20100331232516.GA27730@suse.de>
References: <1269984864-28159-1-git-send-email-agimenez@sysvalve.es> <1270064527-8485-1-git-send-email-agimenez@sysvalve.es> <1270077538.8653.484.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "L. Alberto Gim?nez" <agimenez@sysvalve.es>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, oliver@neukum.org,
	linville@tuxdriver.com, j.dumon@option.com,
	steve.glendinning@smsc.com, davem@davemloft.net, dgiagio@gmail.com,
	dborca@yahoo.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1270077538.8653.484.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 01, 2010 at 12:18:58AM +0100, Ben Hutchings wrote:
> On Wed, 2010-03-31 at 21:42 +0200, L. Alberto Gim??nez wrote:
> [...]
> > --- /dev/null
> > +++ b/drivers/net/usb/ipheth.c
> [...]
> > +#include <linux/kernel.h>
> > +#include <linux/errno.h>
> > +#include <linux/init.h>
> > +#include <linux/slab.h>
> > +#include <linux/module.h>
> > +#include <linux/netdevice.h>
> > +#include <linux/etherdevice.h>
> > +#include <linux/ethtool.h>
> > +#include <linux/uaccess.h>
> 
> I don't think you need this header.
> 
> > +#include <linux/usb.h>
> > +#include <linux/workqueue.h>
> > +
> > +#define USB_VENDOR_APPLE        0x05ac
> > +#define USB_PRODUCT_IPHETH     0x1290
> > +#define USB_PRODUCT_IPHETH_3G   0x1292
> > +#define USB_PRODUCT_IPHETH_3GS  0x1294
> 
> Apple doesn't assign device ids to ipheth so either the names are
> incorrect or you should get proper device ids.  I believe the Linux
> Foundation has a USB vendor id and could assign device ids under that.

You mean there is an application on the iphone that sets the device id
here?  I thought this was the iphone device ids already assigned to
apple.

If we need a linux-specific device id, I can assign them from the Linux
foundations pool of device ids, but so far I've only done that for
devices that either run Linux (usb gadgets), or for the usb root hubs.
But hey, if it's controlable from software, let me know and I'll dole
one out.  In that case, why would you need 3 different device ids?

thanks,

greg k-h
