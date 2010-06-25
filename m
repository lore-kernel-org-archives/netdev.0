From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/8] netpoll: Allow netpoll_setup/cleanup recursion
Date: Thu, 24 Jun 2010 20:50:59 -0700
Message-ID: <20100624205059.a28756b0.akpm@linux-foundation.org>
References: <20100611021142.GA24490@gondor.apana.org.au>
	<E1OMtjk-0006P2-6r@gondolin.me.apana.org.au>
	<20100624182123.45264dfe.akpm@linux-foundation.org>
	<20100624.203006.35035648.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, mst@redhat.com, frzhang@redhat.com,
	netdev@vger.kernel.org, amwang@redhat.com, shemminger@vyatta.com,
	mpm@selenic.com, paulmck@linux.vnet.ibm.com,
	a.p.zijlstra@chello.nl, mingo@elte.hu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60837 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754508Ab0FYDv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 23:51:29 -0400
In-Reply-To: <20100624.203006.35035648.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Jun 2010 20:30:06 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Thu, 24 Jun 2010 18:21:23 -0700
> 
> > Dave, the fixup should be folded into the original patch please -
> > otherwise we'll have a machine-hangs-up bisection hole which spans two
> > weeks work of commits.
> 
> I'm not unwrapping my tree that far back, and there's already been
> a dependent tree pull or two which depend upon the tree past that
> commit, one of it was a rather large wireless merge.
> 
> It's going to screw over too many people.
> 
> We'll just merge the bug fix in, and be done with it.

Sigh.  That really sucks.

What happens if you want to actually *drop* a patch from net-next? 
Surely that happens?

