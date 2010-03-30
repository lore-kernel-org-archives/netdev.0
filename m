From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/7] xfrm: remove policy lock when accessing
	policy->walk.dead
Date: Tue, 30 Mar 2010 22:37:13 +0800
Message-ID: <20100330143713.GA6964@gondor.apana.org.au>
References: <20100329144339.GA26214@gondor.apana.org.au> <4BB1842B.9010704@iki.fi> <20100330115351.GA5731@gondor.apana.org.au> <4BB1E8B1.4030604@iki.fi> <20100330121427.GD5731@gondor.apana.org.au> <4BB1ECBF.50000@iki.fi> <20100330122301.GG5731@gondor.apana.org.au> <4BB1F15E.3030402@iki.fi> <20100330124815.GA6378@gondor.apana.org.au> <4BB1FDC0.5020200@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:32850 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755867Ab0C3OhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 10:37:16 -0400
Content-Disposition: inline
In-Reply-To: <4BB1FDC0.5020200@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 30, 2010 at 04:33:52PM +0300, Timo Ter=E4s wrote:
>
> It also seems that the by-index hash is also used when
> generating new index. It's to double check that the index
> is unique. So deleting the by-index hash from per-socket
> policies seems tricky.
>
> Removing bydst hashing should be trivial.

Yes that makes sense.
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
