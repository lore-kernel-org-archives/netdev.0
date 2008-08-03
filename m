From: David Miller <davem@davemloft.net>
Subject: Re: bad htb_{en,re}queue return codes causing corrupt data in
 drivers
Date: Sun, 03 Aug 2008 00:06:43 -0700 (PDT)
Message-ID: <20080803.000643.88724910.davem@davemloft.net>
References: <20080717213058.GA28252@orion.carnet.hr>
	<20080717.144407.37848445.davem@davemloft.net>
	<20080802122822.GA3222@orion.carnet.hr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joy@entuzijast.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46220
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751999AbYHCHGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 03:06:42 -0400
In-Reply-To: <20080802122822.GA3222@orion.carnet.hr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josip Rodin <joy@entuzijast.net>
Date: Sat, 2 Aug 2008 14:28:22 +0200

> On Thu, Jul 17, 2008 at 02:44:07PM -0700, David Miller wrote:
> > From: Josip Rodin <joy@entuzijast.net>
> > Date: Thu, 17 Jul 2008 23:30:58 +0200
> > 
> > > It looks like the patch fixed my issues - no relevant printk's appeared
> > > since I've applied it, so apparently there is no more cloned skb splitting
> > > or corrupted data getting to bnx2.
> > > 
> > > I used the latest variant, from Jarek's mail
> > > <20080714212223.GA4849@ami.dom.local>, on the 2.6.25.6 kernel.
> > > 
> > > Thanks all!
> > > 
> > > (Now if only someone could make sure this propagates into the stable kernel
> > > branches, since those were pretty nasty crashes...)
> > 
> > We will make sure the fix propagates in some form, thanks for testing.
> 
> Hi again, sorry to bother you, but it's been a few weeks now and I can't
> seem see that fix in any of stable/linux-2.6.2[56].y.git, davem/net-2.6.git,
> sfr/linux-next.git, so I just wanted to check that it hasn't fallen through
> the cracks :)

It hasn't, we're doing an audit of the entire packet scheduler layer
to make sure we fix this bug everywhere it occurs.

Thanks for pinging us.
