From: David Miller <davem@davemloft.net>
Subject: Re: AIM9 regression
Date: Wed, 24 Sep 2008 15:26:21 -0700 (PDT)
Message-ID: <20080924.152621.129282055.davem@davemloft.net>
References: <48DA90BE.5090208@linux-foundation.org>
	<20080924.125346.178957726.davem@davemloft.net>
	<20080924143419.467e0e76@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40289
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752192AbYIXW0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 18:26:32 -0400
In-Reply-To: <20080924143419.467e0e76@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 24 Sep 2008 14:34:19 -0700

> On Wed, 24 Sep 2008 12:53:46 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Christoph Lameter <cl@linux-foundation.org>
> > Date: Wed, 24 Sep 2008 14:10:54 -0500
> > 
> > > Stephen Hemminger wrote:
> > > 
> > > > These loopback benchmarks are often more sensitive to scheduler than networking
> > > > changes.
> > > 
> > > Just ran a test with real NICs which show the same issues. I guess I need to
> > > get familiar with the network stack and start hacking on it. Sigh.
> > 
> > I feel your pain, I think people are being very unreasonable in their
> > analysis of your numbers, and for this I want to personally apologize.
> > 
> > It's clearly a networking issue in my eyes, and I wish my co-developers
> > in networking would treat it as such instead of pushing the blame under
> > the carpet and saying "scheduler", "SLUB", and all kinds of other bullshit
> > without any facts on this specific case to back up such accusations.
> 
> Is this a one time change, or has networking been getting slower over time?

As per the tbench thread, it's been getting slower and slower, every
single release, since as far back as people have tested, which seems
to be 2.6.22 or thereabouts.
