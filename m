From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] addition of a dropped packet notification service
Date: Wed, 25 Feb 2009 16:16:24 +0800
Message-ID: <20090225081624.GA809@gondor.apana.org.au>
References: <20090206165736.295ec007@extreme> <20090207174931.GA10247@localhost.localdomain> <20090209102134.GA8492@gondor.apana.org.au> <20090224.234840.93952093.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35001 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755525AbZBYIQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 03:16:42 -0500
Content-Disposition: inline
In-Reply-To: <20090224.234840.93952093.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2009 at 11:48:40PM -0800, David Miller wrote:
>
> Here's an idea that doesn't use tracepoints (I really don't like
> them, to be honest):
> 
> 1) Isolate the normal packet freeing contexts, have them call
>    kfree_skb_clean() or something like that.
> 
> 2) What remains are the abnormal drop cases.  They still call
>    plain kfree_skb() which records __builtin_return_address(0)
>    and builds a hash table of counts call sites.
> 
> Then you just dump the table via some user visible interface.

This sounds like a great idea to me.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
