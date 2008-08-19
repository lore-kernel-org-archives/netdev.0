From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 18:23:55 +1000
Message-ID: <20080819082355.GA28869@gondor.apana.org.au>
References: <20080819000551.GA26699@gondor.apana.org.au> <20080818.171124.192743795.davem@davemloft.net> <20080818.210701.80578862.davem@davemloft.net> <20080819064609.GA4376@ff.dom.local> <20080819072316.GA4878@gondor.apana.org.au> <20080819073558.GD4376@ff.dom.local> <20080819074606.GA5261@gondor.apana.org.au> <20080819075623.GE4376@ff.dom.local> <20080819080557.GA17977@gondor.apana.org.au> <20080819081713.GF4376@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44957 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751475AbYHSIYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 04:24:03 -0400
Content-Disposition: inline
In-Reply-To: <20080819081713.GF4376@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 08:17:13AM +0000, Jarek Poplawski wrote:
>
> As I've written before I'm mainly concerned with things like
> tcf_destroy_chain(), especially wrt. cls_u32, but I can be wrong with
> this. So, if you don't have such concerns, let's forget it for now,
> and after I look at this more maybe we'll get back to this discussion.

Well I can't vouch for every single qdisc in the tree.  However,
what I can say is that as long as they respect the rules I outlined
earlier with regards to holding the root qdisc lock when deleting
or using children, then they'll work as expected.

You're definitely welcome to audit the qdiscs to make sure that
they are obeying the rules.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
