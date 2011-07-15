From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFC 46/72] ixp2000: Move the Radisys driver
Date: Fri, 15 Jul 2011 12:32:19 +0200
Message-ID: <20110715103219.GQ951@wantstofly.org>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1309010363-22750-47-git-send-email-jeffrey.t.kirsher@intel.com>
 <20110626114721.GA19500@wantstofly.org>
 <1310227137.26989.43.camel@jtkirshe-mobl>
 <20110715000819.GK951@wantstofly.org>
 <1310692758.2628.30.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:57369 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964982Ab1GOKcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 06:32:22 -0400
Content-Disposition: inline
In-Reply-To: <1310692758.2628.30.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 14, 2011 at 06:19:17PM -0700, Jeff Kirsher wrote:

> > > > > Move the Radisys driver into drivers/net/ethernet/radisys/ and
> > > > > make the necessary Kconfig and Makefile changes
> > > > > 
> > > > > CC: Lennert Buytenhek <kernel@wantstofly.org>
> > > > > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > > > > ---
> > > > >  MAINTAINERS                                        |    2 +-
> > > > >  drivers/net/Kconfig                                |    2 --
> > > > >  drivers/net/Makefile                               |    1 -
> > > > >  drivers/net/ethernet/Kconfig                       |    1 +
> > > > >  drivers/net/ethernet/Makefile                      |    1 +
> > > > >  drivers/net/ethernet/radisys/Kconfig               |   16 ++++++++++++++++
> > > > >  drivers/net/ethernet/radisys/Makefile              |    5 +++++
> > > > >  drivers/net/{ => ethernet/radisys}/ixp2000/Kconfig |    2 +-
> > > > >  .../net/{ => ethernet/radisys}/ixp2000/Makefile    |    0
> > > > 
> > > > The ixp2000 is a series of Intel ARM SoCs, and the ENP2611 is a Radisys
> > > > PCI board based on the ixp2000 series (ixp2400), so it doesn't make
> > > > sense to put everything in the radisys/ directory.
> > > 
> > > It was suggested earlier that it probably should be in either ixp/ or
> > > radisys/, and someone suggested that ixp/ might be confusing.  If you
> > > would like to keep it under drivers/net/ethernet/ixp2000, I am fine with
> > > that as well.
> > > 
> > > > If you insist on moving all drivers into vendor directories (I don't
> > > > like that idea at all -- are we going to rename directories and shuffle
> > > > stuff around every time vendor A buys vendor B or takes over one of
> > > > vendor B's products?), at least the core ixp2000 code should be under
> > > > intel/.
> > > 
> > > It was not my preference to place drivers into vendor specific
> > > directories because of that very reason, as I did the work, it just
> > > tended to work out that way.
> > > 
> > > The reason (as stated before) that it was not moved into intel/
> > > directory is because the driver was not written (and supported) by
> > > Intel.
> > 
> > I didn't follow the discussion, but that seems like a silly argument.
> > Does that mean that any non-vendor supported driver can't go into
> > drivers/net/$vendor/?  What if the vendor starts contributing to the
> > driver later on, will the driver be moved then?
> > 
> > It seems that what you're saying is that you don't want the ixp2000
> > driver in "your" subdirectory.
> 
> It is more that all the drivers that in intel/ are all very similar and
> have "common" code which potentially code be shared.  We have been
> looking at what possibilities there are for the common code between the
> Intel supported drivers.  So it really did not make sense to throw a
> driver into the intel/ directory just because it used an Intel chip, but
> has nothing in common with the other drivers in that directory.  Sorry
> if my previous explanation sounded like it I just did not want the
> drivers in the intel/ because we did not write or support it.
> 
> After looking at ixp2000/ixp4xx drivers and the 82586/82596 drivers a
> bit more, I came up with the solution of putting the IXP drivers in
> xscale/ and the 82586/82596 drivers in i825xx/ directory.

That sounds fine with me.
