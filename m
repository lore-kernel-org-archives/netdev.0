From: Josh Boyer <jwboyer@redhat.com>
Subject: Re: [PATCH] netdev: mv643xx_eth: Prevent build on PPC32
Date: Thu, 7 Jun 2012 19:55:51 -0400
Message-ID: <20120607235550.GK7683@zod.bos.redhat.com>
References: <20120605192820.GC7683@zod.bos.redhat.com>
 <1338939005.21665.54.camel@deadeye.wl.decadent.org.uk>
 <20120606023842.GD7683@zod.bos.redhat.com>
 <20120607235115.GB21150@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Andrew Lunn <andrew@lunn.ch>, Olof Johansson <olof@lixom.net>,
	netdev@vger.kernel.org
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12523 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752383Ab2FGX4K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2012 19:56:10 -0400
Content-Disposition: inline
In-Reply-To: <20120607235115.GB21150@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 08, 2012 at 12:51:15AM +0100, Mark Brown wrote:
> On Tue, Jun 05, 2012 at 10:38:42PM -0400, Josh Boyer wrote:
> 
> > 1) revert the change for ARM that introduced th clk stuff
> > 2) do a similar change as the original commit but with a bunch of
> > #ifdef-ery
> > 3) implement the clkdev API stuff for 32-bit ppc
> 
> > Honestly, I'd go for either 1 or 2.  The commit that introduced it was
> > broken to begin with, but that isn't my call.
> 
> There's a change going in which stubs out the clock API when not used
> which should resolve the immediate issue, though really the best thing
> here is just to enable use of the generic clock API if the platform
> doesn't have one of its own - it's not just platforms that need clocks
> so we really want to get that rolled out as widely as possible.

Sounds great.  I have no objections with any of those plans.

> This sort of issue is just the tip of the iceberg in terms of what it's
> useful to do with the API.

Yes, sounds like it.  All I ask is that people test their patches along
the way so things don't get broken.  I mean, it's great we have an
iceberg but I don't want tons of drivers on other architectures running
into the thing and sinking because people aren't being careful.  Except
maybe the one already appropriately (nick)named.

josh
