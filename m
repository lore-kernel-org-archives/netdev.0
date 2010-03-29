From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] r8169: offical fix for CVE-2009-4537 (overlength frame
 DMAs)
Date: Mon, 29 Mar 2010 19:44:56 -0400
Message-ID: <20100329234456.GA2070@localhost.localdomain>
References: <20100329160356.GC22733@hmsreliant.think-freely.org>
 <1269900105.8653.389.camel@localhost>
 <20100329.150924.144366212.davem@davemloft.net>
 <1269901265.8653.408.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, michael.s.gilbert@gmail.com,
	davem@davemeloft.net, romieu@fr.zoreil.com, eric.dumazet@gmail.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1269901265.8653.408.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 29, 2010 at 11:21:05PM +0100, Ben Hutchings wrote:
> On Mon, 2010-03-29 at 15:09 -0700, David Miller wrote:
> > From: Ben Hutchings <ben@decadent.org.uk>
> > Date: Mon, 29 Mar 2010 23:01:45 +0100
> > 
> > > It also sucks that the secure but low-performance behaviour is enabled
> > > for all variants, while AIUI only some suffer from the bug.  I realise
> > > you probably don't have access to every variant (and neither does
> > > Francois) but perhaps you could come up with a test case that could be
> > > used to start whitelisting common variants that don't have the bug?
> > 
> > As far as we know all chip variants seem to have the problem.
> 
> That's not what I understood from the discussion of the early
> back-and-forth changes to receive buffer size.
> 
As dave mentioned, we have no conclusive evidence that only certain chip
variants show the behavior.  realtek hasn't said anything about it one way or
the other.  AFAIK, all you need to do to test given chip is try to receive a
frame thats longer than configured receive filter.  I only had one NIC variant
to test, and it failed that test.

> > Furthermore, this issue has been known about and investigated for
> > about 3 months.  In that time no better options for handling this
> > issue reliably have been discovered and implemented.
> >
> > Feel free to code up (and test) something better yourself if you don't
> > like the fix as it exists currently. :-)
> 
> I would have had a go already, if I actually had some of this hardware
> to hand.  Luckily I have managed to avoid buying any so far.  But if
> anyone is prepared to loan me a NIC then I promise to have a go at it.
> 
I only had the one variant that failed.  My hope was to make them all safe, and,
should any variants be found in the field that didn't exhibit the behavior, we
could whitelist them as they got reported.

Regards
Neil

> Ben.
> 
> -- 
> Ben Hutchings
> Once a job is fouled up, anything done to improve it makes it worse.
