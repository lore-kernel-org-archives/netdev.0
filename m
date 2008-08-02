From: Josip Rodin <joy@entuzijast.net>
Subject: bad htb_{en,re}queue return codes causing corrupt data in drivers [was Re: bnx2_poll panicking kernel]
Date: Sat, 2 Aug 2008 14:28:22 +0200
Message-ID: <20080802122822.GA3222@orion.carnet.hr>
References: <20080714212620.GA8503@orion.carnet.hr> <20080714214851.GB4849@ami.dom.local> <20080717213058.GA28252@orion.carnet.hr> <20080717.144407.37848445.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.CARNet.hr ([161.53.160.90]:34190 "EHLO orion.carnet.hr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750940AbYHBM2Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Aug 2008 08:28:24 -0400
Received: from joy by orion.carnet.hr with local (Exim 4.63)
	(envelope-from <joy@entuzijast.net>)
	id 1KPGDe-0001UO-Mj
	for netdev@vger.kernel.org; Sat, 02 Aug 2008 14:28:22 +0200
Content-Disposition: inline
In-Reply-To: <20080717.144407.37848445.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2008 at 02:44:07PM -0700, David Miller wrote:
> From: Josip Rodin <joy@entuzijast.net>
> Date: Thu, 17 Jul 2008 23:30:58 +0200
> 
> > It looks like the patch fixed my issues - no relevant printk's appeared
> > since I've applied it, so apparently there is no more cloned skb splitting
> > or corrupted data getting to bnx2.
> > 
> > I used the latest variant, from Jarek's mail
> > <20080714212223.GA4849@ami.dom.local>, on the 2.6.25.6 kernel.
> > 
> > Thanks all!
> > 
> > (Now if only someone could make sure this propagates into the stable kernel
> > branches, since those were pretty nasty crashes...)
> 
> We will make sure the fix propagates in some form, thanks for testing.

Hi again, sorry to bother you, but it's been a few weeks now and I can't
seem see that fix in any of stable/linux-2.6.2[56].y.git, davem/net-2.6.git,
sfr/linux-next.git, so I just wanted to check that it hasn't fallen through
the cracks :)

-- 
     2. That which causes joy or happiness.
