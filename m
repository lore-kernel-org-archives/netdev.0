From: Greg KH <gregkh@suse.de>
Subject: Re: Can we have GET_NETDEV_DEV?
Date: Tue, 25 Jul 2006 14:31:27 -0700
Message-ID: <20060725213127.GC9513@suse.de>
References: <1153803145.23803.19.camel@dv> <20060725102005.7edb5509@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Roskin <proski@gnu.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:57272 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S964868AbWGYVfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2006 17:35:36 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060725102005.7edb5509@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 25, 2006 at 10:20:05AM -0700, Stephen Hemminger wrote:
> On Tue, 25 Jul 2006 00:52:25 -0400
> Pavel Roskin <proski@gnu.org> wrote:
> 
> > Hello!
> > 
> > gregkh-driver-network-class_device-to-device.patch, which briefly
> > appeared in Linux 2.6.18-rc1-mm1 broke MadWifi, which is copying the
> > physical device information from the master network device to the
> > virtual network devices:
> > 
> > SET_NETDEV_DEV(dev, mdev->class_dev.dev);
> >
> 
> I would rather see SET_NETDEV_DEV go away. It was done for source
> compatibility between 2.4 and 2.6 network device drivers. This is
> no longer really important.

It did make my change much simpler to do, which I appreciated :)

> It would be better to either access the network device directly.
> BUT, there are plans to get rid of class_dev so that would mean
> source changes to all the drivers again...
> 
> So how about these wrappers.

They look good to me.

BTW, I'll be getting the patch back into -mm that does the class_device
-> device conversion after I fix the SuSE 10.0 release that doesn't like
the change and get that pushed out to users.  After that happens, there
shouldn't be any userspace problems with this patch.

thanks,

greg k-h
