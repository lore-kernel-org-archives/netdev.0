From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Fri, 22 Aug 2008 12:25:15 +0000
Message-ID: <20080822122515.GC14981@ff.dom.local>
References: <20080821185857.GA2665@ami.dom.local> <20080821222330.GE14521@gondor.apana.org.au> <20080822113833.GA14981@ff.dom.local> <20080822.044248.175133807.davem@davemloft.net> <20080822120918.GB14981@ff.dom.local> <20080822121144.GA32397@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:16943 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756369AbYHVMZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 08:25:22 -0400
Received: by nf-out-0910.google.com with SMTP id d3so202064nfc.21
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2008 05:25:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080822121144.GA32397@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 10:11:44PM +1000, Herbert Xu wrote:
> On Fri, Aug 22, 2008 at 12:09:18PM +0000, Jarek Poplawski wrote:
> >
> > I guess, we need to establish first how much it's needed on fast
> > paths. But anyway, it seems something like qdisc_match_from_root()
> > should be enough in this qdisc_tree_decrease_qlen().
> 
> Or we could just replace requeue with a peek interface.

...Or with a kfree_skb() interface ;) That's just to establish.

Jarek P.
