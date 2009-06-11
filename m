From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ip_gre headroom allocation
Date: Thu, 11 Jun 2009 21:37:09 +1000
Message-ID: <20090611113709.GA2545@gondor.apana.org.au>
References: <4A30BECA.8030205@iki.fi> <20090611.030922.91415233.davem@davemloft.net> <4A30D9AA.1020004@iki.fi> <20090611105638.GA2085@gondor.apana.org.au> <4A30EAAA.4070907@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57580 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1763035AbZFKLhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 07:37:12 -0400
Content-Disposition: inline
In-Reply-To: <4A30EAAA.4070907@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2009 at 02:29:46PM +0300, Timo Ter=E4s wrote:
>
> I guess this is easy for point-to-point tunnels. But how about the
> multipoint gre tunnels? The needed_headroom can vary on destination
> basis depending on if they are NATted or not, and on the cipher/hash
> used.

I don't think we need to worry about NAT, well at least we don't
worry about it on the normal path :)

> Can we change the needed_headroom on-the-fly? Increase it when ever
> we encounter a larger path? But this also means some packages would
> get extra headroom allocated.

Just make it the maximum.  It's OK to have extra head space.
If the head space is huge then you've got bigger problems than
wasted memory :)

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
