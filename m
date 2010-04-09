From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Crashes in xfrm_lookup
Date: Fri, 9 Apr 2010 16:22:40 +0800
Message-ID: <20100409082239.GA2194@gondor.apana.org.au>
References: <20100409080907.GA2029@gondor.apana.org.au> <4BBEE144.8070600@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: broonie@opensource.wolfsonmicro.com, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:34472 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754074Ab0DIIWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 04:22:47 -0400
Content-Disposition: inline
In-Reply-To: <4BBEE144.8070600@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 09, 2010 at 11:11:48AM +0300, Timo Ter=E4s wrote:
>
> It's still really misleading to have generic function that does not
> do the expected thing based on some config. Compiler should know
> how to optimize the for loop away if it's being called with fixed
> array size.

But the compiler doesn't know because your patch makes it an
array unconditionally.

The SUB_POLICY stuff was a hack from the very start, but at least
you could compile it out previously.  Now it'll pollute things
regardless of the configuration.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
