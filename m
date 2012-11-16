From: Jon Mason <jon.mason@intel.com>
Subject: Re: [PATCH v5 2/2] net: Add support for NTB virtual ethernet device
Date: Thu, 15 Nov 2012 18:13:53 -0700
Message-ID: <20121116011353.GK24723@jonmason-lab>
References: <1352160669-4330-1-git-send-email-jon.mason@intel.com>
 <1352160669-4330-3-git-send-email-jon.mason@intel.com>
 <20121116003043.GC20876@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121116003043.GC20876@kroah.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 15, 2012 at 04:30:43PM -0800, Greg KH wrote:
> On Mon, Nov 05, 2012 at 05:11:09PM -0700, Jon Mason wrote:
> > A virtual ethernet device that uses the NTB transport API to
> > send/receive data.
> > 
> > Signed-off-by: Jon Mason <jon.mason@intel.com>
> > Reviewed-by: Nicholas Bellinger <nab@linux-iscsi.org>
> > ---
> >  MAINTAINERS              |    1 +
> >  drivers/net/Kconfig      |    4 +
> >  drivers/net/Makefile     |    1 +
> >  drivers/net/ntb_netdev.c |  415 ++++++++++++++++++++++++++++++++++++++++++++++
> 
> As I haven't taken the core yet, I can't take this.  But even then, I
> would need an ack from the network maintainers before I could.

I have been Cc'ing netdev on these patches and gotten many good
comments, but I can cc Dave Miller explicitly on my next version (as
there will obviously need to be one based on your comments on the
previous patch).

> 
> And are you sure this is in the correct location in the tree?

I assumed that the virtual network client that uses NTB as a transport
would best fit in the network drivers.  Is this a bad assumption?

Thanks,
Jon
> 
> thanks,
> 
> greg k-h
