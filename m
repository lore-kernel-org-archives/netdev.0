From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Wed, 24 Sep 2008 14:13:49 +0800
Message-ID: <20080924061349.GA6679@gondor.apana.org.au>
References: <20080923130709.GA29902@gondor.apana.org.au> <48D8EF5E.1060500@iki.fi> <20080923133234.GA30370@gondor.apana.org.au> <48D8F337.2050103@iki.fi> <20080924042349.GA5419@gondor.apana.org.au> <48D9CCA3.2040500@iki.fi> <20080924051555.GA6218@gondor.apana.org.au> <48D9D421.9050500@iki.fi> <20080924055550.GA6506@gondor.apana.org.au> <48D9D86E.7020205@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35686 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750875AbYIXGN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 02:13:57 -0400
Content-Disposition: inline
In-Reply-To: <48D9D86E.7020205@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2008 at 09:04:30AM +0300, Timo Ter=E4s wrote:
>
> Or at least add a comment to the dumping function to say that
> we have struct xfrm_state, but in matter of fact it can be
> also struct xfrm_state_walk pointer with displacement, so we
> better check km.state first.

Which is exactly what we do.  The first thing we check in the
loop is km.state.  I really don't see your problem.

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
