From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: Getting physical packet counts with LRO enabled with ixgbe?
Date: Fri, 25 Sep 2009 15:40:32 -0700
Message-ID: <1253918432.3809.32.camel@localhost.localdomain>
References: <20090925214505.GA3472@gondor.apana.org.au>
	 <4ABD3B34.8010903@candelatech.com>
	 <20090925.145915.68839478.davem@davemloft.net>
	 <20090925220115.GA3684@gondor.apana.org.au>
	 <4ABD405D.2030106@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9821 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750992AbZIYWkY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2009 18:40:24 -0400
In-Reply-To: <4ABD405D.2030106@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-09-25 at 15:12 -0700, Ben Greear wrote:
> On 09/25/2009 03:01 PM, Herbert Xu wrote:
> > On Fri, Sep 25, 2009 at 02:59:15PM -0700, David Miller wrote:
> >> From: Ben Greear<greearb@candelatech.com>
> >> Date: Fri, 25 Sep 2009 14:50:44 -0700
> >>
> >>> I get aggregate 18Gbps with LRO v/s 12Gbps without, so it's very
> >>> much a useful feature for me.
> >>
> >> And it'll stay like that until you work with Herbert to fix
> >> that performance difference.
> >
> > Actually I believe he's talking about hardware LRO which is a
> > different beast.
> >
> > AFAICS the ixgbe driver doesn't use software LRO anymore.
> >
> > So if it is hardware LRO then what we need is for the hardware
> > to switch over :)
> 
> Either way, I will be happy to test & benchmark patches of this nature
> if someone wants to post them.
> 

I can't post a patch that changes my hardware behavior.  :-)

So to be clear, ixgbe uses GRO, and does not use software LRO.  In 82599
adapters, we have a HW LRO engine.  So we run HW LRO and GRO together.
What Herbert is referring to is that we change our HW design of the HW
LRO engine to do more of what GRO is doing today.  That would require a
silicon spin, so that wouldn't happen soon unfortunately.

-PJ

