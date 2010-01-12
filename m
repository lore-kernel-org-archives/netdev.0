From: Greg KH <gregkh@suse.de>
Subject: Re: Can we remove pci_find_device() yet?
Date: Mon, 11 Jan 2010 16:46:35 -0800
Message-ID: <20100112004635.GA10597@suse.de>
References: <20100108112236.462a3da2.sfr@canb.auug.org.au>
 <20100108044646.GC6611@suse.de>
 <4B4B802A.2010709@imap.cc>
 <20100111200136.GA29955@suse.de>
 <20100112112115.98009d50.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tilman Schmidt <tilman@imap.cc>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38143 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751249Ab0ALArR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2010 19:47:17 -0500
Content-Disposition: inline
In-Reply-To: <20100112112115.98009d50.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2010 at 11:21:15AM +1100, Stephen Rothwell wrote:
> Hi Greg,
> 
> On Mon, 11 Jan 2010 12:01:36 -0800 Greg KH <gregkh@suse.de> wrote:
> >
> > Close, but if you do this, please name the function
> > hisax_find_pci_device() or something, and change the drivers to use it
> > instead.  Also put a big fat warning in the function that calling this
> > is unsafe for any PCI hotplug type machine.
> 
> There is another implementation of pci_find_device in
> drivers/staging/dt3155/pci-compat.h (used by dt3155_drv.c).

That file will be going away soon and the whole driver will be ported to
use the "real" PCI api, so don't worry about breaking any staging
drivers :)

thanks,

greg k-h
