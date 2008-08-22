From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Fix qdisc list locking
Date: Fri, 22 Aug 2008 20:14:08 +1000
Message-ID: <20080822101408.GB14345@gondor.apana.org.au>
References: <20080821124834.GA8794@gondor.apana.org.au> <20080821204052.GB2665@ami.dom.local> <20080821222446.GF14521@gondor.apana.org.au> <20080822084150.GA2645@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51891 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753072AbYHVKOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 06:14:15 -0400
Content-Disposition: inline
In-Reply-To: <20080822084150.GA2645@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 08:41:50AM +0000, Jarek Poplawski wrote:
> 
> It looks like adding to the list needs similar protection, but if I
> exagerated here let me know.

Yes I agree.  List addition is certainly not safe for walkers
without memory barriers.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
