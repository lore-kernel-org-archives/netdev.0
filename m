From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8] netpoll: Allow netpoll_setup/cleanup recursion
Date: Thu, 24 Jun 2010 20:30:06 -0700 (PDT)
Message-ID: <20100624.203006.35035648.davem@davemloft.net>
References: <20100611021142.GA24490@gondor.apana.org.au>
	<E1OMtjk-0006P2-6r@gondolin.me.apana.org.au>
	<20100624182123.45264dfe.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, mst@redhat.com, frzhang@redhat.com,
	netdev@vger.kernel.org, amwang@redhat.com, shemminger@vyatta.com,
	mpm@selenic.com, paulmck@linux.vnet.ibm.com,
	a.p.zijlstra@chello.nl, mingo@elte.hu
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41788
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754380Ab0FYD3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 23:29:55 -0400
In-Reply-To: <20100624182123.45264dfe.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 24 Jun 2010 18:21:23 -0700

> Dave, the fixup should be folded into the original patch please -
> otherwise we'll have a machine-hangs-up bisection hole which spans two
> weeks work of commits.

I'm not unwrapping my tree that far back, and there's already been
a dependent tree pull or two which depend upon the tree past that
commit, one of it was a rather large wireless merge.

It's going to screw over too many people.

We'll just merge the bug fix in, and be done with it.
