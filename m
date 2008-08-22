From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Fri, 22 Aug 2008 22:11:44 +1000
Message-ID: <20080822121144.GA32397@gondor.apana.org.au>
References: <20080821185857.GA2665@ami.dom.local> <20080821222330.GE14521@gondor.apana.org.au> <20080822113833.GA14981@ff.dom.local> <20080822.044248.175133807.davem@davemloft.net> <20080822120918.GB14981@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57022 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752840AbYHVMLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 08:11:52 -0400
Content-Disposition: inline
In-Reply-To: <20080822120918.GB14981@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 12:09:18PM +0000, Jarek Poplawski wrote:
>
> I guess, we need to establish first how much it's needed on fast
> paths. But anyway, it seems something like qdisc_match_from_root()
> should be enough in this qdisc_tree_decrease_qlen().

Or we could just replace requeue with a peek interface.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
