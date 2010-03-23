From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Tue, 23 Mar 2010 15:42:52 +0800
Message-ID: <20100323074252.GA27623@gondor.apana.org.au>
References: <20100319093210.GA23895@gondor.apana.org.au> <4BA349A8.9050105@iki.fi> <20100320151751.GB2950@gondor.apana.org.au> <4BA4F718.3020700@iki.fi> <20100321004659.GA5895@gondor.apana.org.au> <4BA5CC16.9040606@iki.fi> <4BA5D95B.4020004@iki.fi> <20100322035201.GA14457@gondor.apana.org.au> <4BA7B10A.1030302@iki.fi> <4BA86DA1.7090707@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44409 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752272Ab0CWHm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 03:42:59 -0400
Content-Disposition: inline
In-Reply-To: <4BA86DA1.7090707@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 23, 2010 at 09:28:33AM +0200, Timo Ter=E4s wrote:
>
> So, should I go ahead and do the virtualization of the
> getters and putters?

If we're going to have indirect calls per packet then let's at
least minimise them.  I think one should be enough, i.e., just
add a ->stale() function pointer to be used in flow_cache_lookup.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
