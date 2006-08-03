From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] e1000: add forgotten PCI ID for supported device
Date: Thu, 3 Aug 2006 00:17:42 -0700
Message-ID: <20060803071742.GL26354@kroah.com>
References: <44CA8A59.40002@intel.com> <20060728231837.GA2109@kroah.com> <Pine.WNT.4.63.0607281659480.2660@jbrandeb-desk.amr.corp.intel.com> <20060729002440.GA3284@kroah.com> <20060729031859.GA23779@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	NetDev <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:61666 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S932357AbWHCHWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 03:22:21 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20060729031859.GA23779@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2006 at 11:19:05PM -0400, John W. Linville wrote:
> On Fri, Jul 28, 2006 at 05:24:40PM -0700, Greg KH wrote:
> > On Fri, Jul 28, 2006 at 05:04:49PM -0700, Brandeburg, Jesse wrote:
> 
> > > The kernel driver advertises through our probe table and in our readme 
> > > that we support this device (code is in e1000_main.c) but we don't load on 
> > > it correctly due to an error when we submitted the patches (e1000_hw.c/h).
> > > 
> > > Patch is very simple and low risk, but it is your call.
> > 
> > Sorry, but for now, no.  Users should be able to use the sysfs bind and
> > new_id interface to add new device support for your driver, if it's
> > written properly :)
> 
> In this case it isn't an addition to the PCI ID table, but an actual
> added check in the code.  You could make the argument that it is a
> bug since the PCI ID table says the device is supported, but it won't
> work w/o this additional check.

Ok, fine, you all convinced me :)

Queued to -stable.

thanks,

greg k-h

