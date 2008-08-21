From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Fri, 22 Aug 2008 08:24:47 +1000
Message-ID: <20080821222446.GF14521@gondor.apana.org.au>
References: <20080821124834.GA8794@gondor.apana.org.au> <20080821204052.GB2665@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60227 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759755AbYHUWYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 18:24:52 -0400
Content-Disposition: inline
In-Reply-To: <20080821204052.GB2665@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 10:40:53PM +0200, Jarek Poplawski wrote:
>
> If it's really needed, then OK with me, but tx_global_lock doesn't
> look like the best choice, considering it can be used here with
> qdisc root lock, and this comment from sch_generic:

Sure, that was just an illustration of what I meant.  It doesn't
even compile :)

Feel free to fix this up into a real patch with a new lock.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
