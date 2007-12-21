From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH]  New driver "sfc" for Solarstorm SFC4000 controller - 3nd try
Date: Fri, 21 Dec 2007 18:30:07 +0000
Message-ID: <20071221183006.GA8717@solarflare.com>
References: <476BEF94.4000801@solarflare.com> <20071221100253.fb5b0899.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rutherford.zen.co.uk ([212.23.3.142]:56929 "EHLO
	rutherford.zen.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752627AbXLUSaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 13:30:10 -0500
Content-Disposition: inline
In-Reply-To: <20071221100253.fb5b0899.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Randy Dunlap wrote:
> On Fri, 21 Dec 2007 16:53:40 +0000 Robert Stonehouse wrote:
> 
> > This is a resubmission of a new driver for Solarflare network controllers.
<snip>
> > The last two patches were marked with RFC but I now think that this driver
> > is ready (withstanding any further review comments) and I would like to ask
> > that this driver is considered for merging.
> > 
> > 
> > The patch (against net-2.6.25) is at:
> >      https://support.solarflare.com/netdev/3/net-2.6.25-sfc-2.2.0029.patch
> 
> wow, 750+ KB
> 
> How many drivers is this?

Just two: sfc (net) and sfc_mtd (MTD).  As Robert said, the net driver
supports a variety of PHYs.  It also has a fair amount of self-test
and (conditional) debug code, and comments.

I've noted your comments on kernel-doc and Kconfig format and will
address those in the next version.

<snip>
> c.  Driver contains MTD, SPI, & I2C (at least) code and needs to be
> reviewed by people in those areas as well (IMO).
> 
> I see an MTD dependency in the Kconfig file.
> What about the SPI and I2C parts?  Are they conditional or
> how is that handled?  or does the driver not use the kernel
> infrastructure for these?

We are not currently using the kernel infrastructure for those.
I'm not sure whether we could do.

I think everyone working on the net driver here will be away until
the new year, so please forgive our silence in the mean time.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
