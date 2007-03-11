From: Adrian Bunk <bunk@stusta.de>
Subject: Re: SSB/b44 build failure
Date: Sun, 11 Mar 2007 18:22:01 +0100
Message-ID: <20070311172201.GJ18731@stusta.de>
References: <1173496449.13449@shark.he.net> <20070310150346.GB5062@tuxdriver.com> <20070310153816.GP3441@stusta.de> <20070310162240.GA3489@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Randy Dunlap <rdunlap@xenotime.net>, mb@bu3sch.de,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:56399 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933846AbXCKRV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2007 13:21:59 -0400
Content-Disposition: inline
In-Reply-To: <20070310162240.GA3489@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 10, 2007 at 11:22:40AM -0500, John W. Linville wrote:
> On Sat, Mar 10, 2007 at 04:38:16PM +0100, Adrian Bunk wrote:
> > On Sat, Mar 10, 2007 at 10:03:46AM -0500, John W. Linville wrote:
> 
> > > diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> > > index 6a4325b..b2e1deb 100644
> > > --- a/drivers/net/Kconfig
> > > +++ b/drivers/net/Kconfig
> > > @@ -1402,6 +1402,7 @@ config B44
> > >  config B44_PCI
> > >  	bool "Broadcom 4400 PCI device support"
> > >  	depends on B44 && NET_PCI
> > > +	select SSB_PCIHOST
> > >  	default y
> > >  	help
> > >  	  Support for b44 PCI devices.
> > 
> > 
> > This also requires a depends or select on SSB.
> 
> It depends on B44, which selects SSB.

Oops, you are correct.

> John

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

