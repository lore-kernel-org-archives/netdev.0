From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Wed, 3 Sep 2008 15:40:20 +1000
Message-ID: <20080903054020.GA8479@gondor.apana.org.au>
References: <E1KakUR-0001xp-00@gondolin.me.apana.org.au> <48BE1B95.8000508@iki.fi> <20080903052329.GA8134@gondor.apana.org.au> <48BE2306.8070101@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46475 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751662AbYICFkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 01:40:25 -0400
Content-Disposition: inline
In-Reply-To: <48BE2306.8070101@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 03, 2008 at 08:39:18AM +0300, Timo Ter=E4s wrote:
>=20
> Oh, I seemed to have missed that there was multiple places where
> the list insertion happens. Would it make sense to make function
> for inserting the entries in the lists?

Sure, grep for the places that change xfrm_state_num and you've
got your function :)

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
