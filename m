From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ip_gre headroom allocation
Date: Thu, 11 Jun 2009 22:12:36 +1000
Message-ID: <20090611121236.GA2866@gondor.apana.org.au>
References: <4A30BECA.8030205@iki.fi> <20090611.030922.91415233.davem@davemloft.net> <4A30D9AA.1020004@iki.fi> <20090611105638.GA2085@gondor.apana.org.au> <4A30EAAA.4070907@iki.fi> <20090611113709.GA2545@gondor.apana.org.au> <4A30EFBE.6080106@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41928 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752075AbZFKMMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 08:12:39 -0400
Content-Disposition: inline
In-Reply-To: <4A30EFBE.6080106@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2009 at 02:51:26PM +0300, Timo Ter=E4s wrote:
>
> I guess so. The difference is not too many bytes. Is it ok to just
> change the dev->needed_headroom from xmit routine?

I don't see why not.  Also we only need to change it in xmit if
we hit an skb that needs to be reallocated.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
