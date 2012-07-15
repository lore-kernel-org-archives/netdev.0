From: Greg KH <greg@kroah.com>
Subject: Re: [RFC 1/2] PCI-Express Non-Transparent Bridge Support
Date: Sun, 15 Jul 2012 16:53:30 -0700
Message-ID: <20120715235330.GA30641@kroah.com>
References: <1342215900-3358-1-git-send-email-jon.mason@intel.com>
 <20120714170411.GA25775@kroah.com>
 <20120715235041.GB7551@jonmason-lab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>
To: Jon Mason <jon.mason@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:56067 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750716Ab2GOXxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2012 19:53:33 -0400
Content-Disposition: inline
In-Reply-To: <20120715235041.GB7551@jonmason-lab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 15, 2012 at 04:50:41PM -0700, Jon Mason wrote:
> On Sat, Jul 14, 2012 at 10:04:11AM -0700, Greg KH wrote:
> > On Fri, Jul 13, 2012 at 02:44:59PM -0700, Jon Mason wrote:
> > > The NTB device driver is needed to configure these memory windows, doorbell, and
> > > scratch-pad registers as well as use them in such a way as they can be turned
> > > into a viable communication channel to the remote system.  ntb_hw.[ch]
> > > determines the usage model (NTB to NTB or NTB to Root Port) and abstracts away
> > > the underlying hardware to provide access and a common interface to the doorbell
> > > registers, scratch pads, and memory windows.  These hardware interfaces are
> > > exported so that other, non-mainlined kernel drivers can access these.
> > 
> > Why would you have non-mainlined drivers?
> > 
> > Can you submit the drivers at the same time so we see how you are using
> > these new interfaces?
> 
> There are none at this time.  In the near future, the transport will
> be modified to use IOAT instead of the CPU copy to improve throughput
> performance, and it may be beneficial to have that separate.  If you
> wish for me to remove the hooks until it is necessary for that, then I
> can.

Yes, please do so, we don't add apis for things that are not in-kernel
as they almost always need to change once we actually get a user of
them, as you know.

thanks,

greg k-h
