From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sat, 3 Apr 2010 22:17:09 +0800
Message-ID: <20100403141709.GA5165@gondor.apana.org.au>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi> <1270126340-30181-2-git-send-email-timo.teras@iki.fi> <20100403033857.GA2205@gondor.apana.org.au> <20100403083609.GA3654@gondor.apana.org.au> <4BB74790.7070109@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:57436 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754168Ab0DCORN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Apr 2010 10:17:13 -0400
Content-Disposition: inline
In-Reply-To: <4BB74790.7070109@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 03, 2010 at 04:50:08PM +0300, Timo Ter=E4s wrote:
>
> The flow cache is randomized every ten minutes. Thus all flow
> cache entries get recreated regularly.

Having rmmod <netdrv> block for up to ten minutes is hardly
ideal.

Besides, in future we may want to get rid of the regular reseeding
just like we did for IPv4 routes.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
