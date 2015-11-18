From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Wed, 18 Nov 2015 15:39:19 +1030
Message-ID: <20151118050919.GR25216@marvin.atrad.com.au>
References: <20130309064647.GC4984@marvin.atrad.com.au>
 <20130311000216.GA31808@zoreil.com>
 <20130405001526.GC19253@marvin.atrad.com.au>
 <20151117015605.GI22941@marvin.atrad.com.au>
 <20151117232108.GC3362@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.atrad.com.au ([150.101.241.2]:38641 "EHLO
	server.atrad.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763AbbKRFJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 00:09:28 -0500
Content-Disposition: inline
In-Reply-To: <20151117232108.GC3362@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 18, 2015 at 12:21:08AM +0100, Francois Romieu wrote:
> Jonathan Woithe <jwoithe@atrad.com.au> :
> [...]
> > It would be advantageous if we could upgrade this Linux system to a kernel
> > more recent than 2.6.35.11, but that will require a resolution to this
> > problem.  Since 2.6.35.11 works while current kernels do not, the only other
> > option is to stick with 2.6.35.11.  Is there anything we can do to try to
> > track down the problem?  I'm willing and able to run further tests on the
> > system as required.
> 
> If you were tracking the hardware stats (ethtool -S), would you be able to
> tell if the hardware sees the relevant UDP packets long before the driver
> does ?

Possibly.  The packet flow at the time of fault is quite low so it might be
doable.  What would be the best way to approach this?  Query "ethtool -S"
regularly around the point of failure?

> Would you be able to ascertain that the interrupt mask register (ethtool -d)
> is not set for an excessive amount of time ?

I could try.  What's the most reliable way to determine this?  Use regular
ethtool queries about the time of the failures?

Regards
  jonathan
