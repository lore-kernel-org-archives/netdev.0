From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 23:12:18 +1000
Message-ID: <20080821131218.GA9208@gondor.apana.org.au>
References: <20080821120112.GA7705@gondor.apana.org.au> <20080821121920.GD4079@ff.dom.local> <20080821122245.GA8533@gondor.apana.org.au> <20080821.052754.104318066.davem@davemloft.net> <20080821123538.GA8703@gondor.apana.org.au> <20080821124834.GA8794@gondor.apana.org.au> <20080821125501.GF4079@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42986 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755222AbYHUNMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 09:12:24 -0400
Content-Disposition: inline
In-Reply-To: <20080821125501.GF4079@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 12:55:01PM +0000, Jarek Poplawski wrote:
> 
> Alas I've to have a break now, anyway I think for now "my" proposal
> should be safer since it worked like this before... But of course
> after good checking your patch should be better.

Well your patch doesn't work and my patch doesn't compile :)

The problem is that qdisc_lookup walks through every txq's list while
the sch_tree_lock protects a single txq only.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
