From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: SSB/b44 build failure
Date: Sat, 10 Mar 2007 11:22:40 -0500
Message-ID: <20070310162240.GA3489@tuxdriver.com>
References: <1173496449.13449@shark.he.net> <20070310150346.GB5062@tuxdriver.com> <20070310153816.GP3441@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Randy Dunlap <rdunlap@xenotime.net>, mb@bu3sch.de,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3213 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933485AbXCJRFh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2007 12:05:37 -0500
Content-Disposition: inline
In-Reply-To: <20070310153816.GP3441@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 10, 2007 at 04:38:16PM +0100, Adrian Bunk wrote:
> On Sat, Mar 10, 2007 at 10:03:46AM -0500, John W. Linville wrote:

> > diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> > index 6a4325b..b2e1deb 100644
> > --- a/drivers/net/Kconfig
> > +++ b/drivers/net/Kconfig
> > @@ -1402,6 +1402,7 @@ config B44
> >  config B44_PCI
> >  	bool "Broadcom 4400 PCI device support"
> >  	depends on B44 && NET_PCI
> > +	select SSB_PCIHOST
> >  	default y
> >  	help
> >  	  Support for b44 PCI devices.
> 
> 
> This also requires a depends or select on SSB.

It depends on B44, which selects SSB.

John
-- 
John W. Linville
linville@tuxdriver.com
