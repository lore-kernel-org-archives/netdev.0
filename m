From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Fri, 26 Sep 2008 10:08:04 +0800
Message-ID: <20080926020804.GA27137@gondor.apana.org.au>
References: <48DA3E2D.4070909@iki.fi> <20080924140819.GA10022@gondor.apana.org.au> <48DB29A9.2090204@iki.fi> <20080925075715.GA18101@gondor.apana.org.au> <48DB4EE7.2030109@iki.fi> <20080925085634.GA18853@gondor.apana.org.au> <48DB536A.7020209@iki.fi> <20080925094905.GA19180@gondor.apana.org.au> <48DB801E.90500@iki.fi> <48DB85B4.10104@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43499 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751506AbYIZCIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 22:08:13 -0400
Content-Disposition: inline
In-Reply-To: <48DB85B4.10104@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2008 at 03:36:04PM +0300, Timo Ter=E4s wrote:
>
> The right place to do that would be pfkey_release, I assume?

Yes that sounds right.

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
