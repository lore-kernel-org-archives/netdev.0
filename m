From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 11:20:56 +0000
Message-ID: <20080821112055.GB4079@ff.dom.local>
References: <20080819085504.GB29038@gondor.apana.org.au> <20080819091642.GI4376@ff.dom.local> <20080821100155.GA3621@ff.dom.local> <20080821.030523.205239441.davem@davemloft.net> <20080821101145.GA3963@ff.dom.local> <20080821101830.GB3963@ff.dom.local> <20080821102153.GB3789@gondor.apana.org.au> <20080821102338.GA3864@gondor.apana.org.au> <20080821103354.GA4079@ff.dom.local> <20080821105110.GA4088@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:8259 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755363AbYHULVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 07:21:02 -0400
Received: by ug-out-1314.google.com with SMTP id c2so1004302ugf.37
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 04:21:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080821105110.GA4088@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 08:51:10PM +1000, Herbert Xu wrote:
> On Thu, Aug 21, 2008 at 10:33:54AM +0000, Jarek Poplawski wrote:
> >
> > > > Where do they use qdisc->list?
> > > 
> > > For the next development tree we could even add an ASSERT_RTNL to
> > > qdisc_lookup and co to ensure that nobody abuses this interface.
> > 
> > But if I get above right, you acknowledge the problem currently exists?
> 
> Why don't you just point out the problems that you see rather
> than hypothesising :)

I thought I described the problem quite clearly, except this error in
the lock name. I certainly can miss much more things than you. And,
after your answer I'm simply not sure if the question is still valid.

Jarek P.
