From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Thu, 25 Sep 2008 16:56:34 +0800
Message-ID: <20080925085634.GA18853@gondor.apana.org.au>
References: <20080924061349.GA6679@gondor.apana.org.au> <48D9DC1A.10903@iki.fi> <20080924062138.GA6764@gondor.apana.org.au> <48D9EC4B.4050804@iki.fi> <20080924075441.GA7391@gondor.apana.org.au> <48DA3E2D.4070909@iki.fi> <20080924140819.GA10022@gondor.apana.org.au> <48DB29A9.2090204@iki.fi> <20080925075715.GA18101@gondor.apana.org.au> <48DB4EE7.2030109@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35046 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752878AbYIYI4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 04:56:42 -0400
Content-Disposition: inline
In-Reply-To: <48DB4EE7.2030109@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2008 at 11:42:15AM +0300, Timo Ter=E4s wrote:
>
> Maybe we should make af_key.c code instead cache one entry before
> sending it to user space. We could then get rid of the last hack
> inside xfrm core walking code.

Yes that should work.  But you want to keep cache the skb instead
of the state since the latter can die.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
