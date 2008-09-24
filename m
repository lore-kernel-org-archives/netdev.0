From: David Miller <davem@davemloft.net>
Subject: Re: AIM9 regression
Date: Wed, 24 Sep 2008 12:36:57 -0700 (PDT)
Message-ID: <20080924.123657.217162945.davem@davemloft.net>
References: <20080924051237.GA6173@gondor.apana.org.au>
	<20080923.221831.126801015.davem@davemloft.net>
	<20080924081603.08a5f808@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, cl@linux-foundation.org,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38998
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752040AbYIXThI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 15:37:08 -0400
In-Reply-To: <20080924081603.08a5f808@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 24 Sep 2008 08:16:03 -0700

> On Tue, 23 Sep 2008 22:18:31 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Herbert Xu <herbert@gondor.apana.org.au>
> > Date: Wed, 24 Sep 2008 13:12:37 +0800
> > 
> > > On Tue, Sep 23, 2008 at 01:14:27PM -0500, Christoph Lameter wrote:
> > > > I just dont seem to be able to get 2.6.27 to behave in a speedy way network
> > > > wise. Configured out various components (netfilter, etc etc) but I still keep
> > > > getting these aim9 result against 2.6.22:
> > > 
> > > Could you please compare this against something less ancient,
> > > like 2.6.26 perhaps?
> > 
> > Herbert, this is part of the tbench regression issues.  Christoph
> > took tbench from 2.6.22 until 2.6.27 and at basically every release
> > tbench performance suffered noticably.
> > 
> > Now, he's taking the AIM9 benchmark networking numbers and showing
> > that the same exact effect is seen there too.
> > 
> > It really behooves us to start doing something proactive about this
> > blindingly obvious set of networking performance regressions through
> > the past 6 or so releases instead of barking at the reporters saying
> > things like "try this, try that, what's your config" etc.
> > 
> > :-)
> 
> These loopback benchmarks are often more sensitive to scheduler than networking
> changes.

When it gets to %20, I strong start to doubt that, and this is exactly
what's happening here.

What is it going to take to actually get someone to start profiling and
analyzing this?  :-)

