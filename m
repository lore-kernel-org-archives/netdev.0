From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Wed, 24 Sep 2008 22:08:19 +0800
Message-ID: <20080924140819.GA10022@gondor.apana.org.au>
References: <20080924051555.GA6218@gondor.apana.org.au> <48D9D421.9050500@iki.fi> <20080924055550.GA6506@gondor.apana.org.au> <48D9D86E.7020205@iki.fi> <20080924061349.GA6679@gondor.apana.org.au> <48D9DC1A.10903@iki.fi> <20080924062138.GA6764@gondor.apana.org.au> <48D9EC4B.4050804@iki.fi> <20080924075441.GA7391@gondor.apana.org.au> <48DA3E2D.4070909@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57800 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752095AbYIXOI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 10:08:28 -0400
Content-Disposition: inline
In-Reply-To: <48DA3E2D.4070909@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2008 at 04:18:37PM +0300, Timo Ter=E4s wrote:
>
> Gave it a test spin and found one bug. The walking routine will
> get called one extra time when it has successfully dumped
> everything so we need to check for that in the beginning; the
> earlier version would start all over from the beginning resulting
> never ending dumps.

Aha, that's why the if statement was there :)

Thanks for all the work!
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
