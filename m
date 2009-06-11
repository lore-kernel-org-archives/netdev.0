From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ip_gre headroom allocation
Date: Thu, 11 Jun 2009 20:56:38 +1000
Message-ID: <20090611105638.GA2085@gondor.apana.org.au>
References: <4A30BECA.8030205@iki.fi> <20090611.030922.91415233.davem@davemloft.net> <4A30D9AA.1020004@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53322 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757075AbZFKK44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 06:56:56 -0400
Content-Disposition: inline
In-Reply-To: <4A30D9AA.1020004@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2009 at 01:17:14PM +0300, Timo Ter=E4s wrote:
>
>> Otherwise we'd need a similar hack in ipip.c too.
>
> I was under the impression that as we need to do the route lookup any=
way
> we could take advantage of the information available from there fully=
=2E
>
> But yes, your explanation makes perfect sense.

I think you're both right :)

We should include the IPsec head room here, but also in the
dev->needed_headroom calculation so that most packets don't
get reallocated in the first place.

And yes all tunnels are deficient in this regard.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
