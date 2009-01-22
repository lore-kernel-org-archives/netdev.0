From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Thu, 22 Jan 2009 17:22:56 +1100
Message-ID: <20090122062256.GA11337@gondor.apana.org.au>
References: <20090121223329.GA8522@gondor.apana.org.au> <20090121.144054.70937985.davem@davemloft.net> <49780AA9.9050508@iki.fi> <20090121.220304.211246256.davem@davemloft.net> <49780EB5.60300@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53898 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754244AbZAVGXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 01:23:05 -0500
Content-Disposition: inline
In-Reply-To: <49780EB5.60300@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2009 at 08:14:13AM +0200, Timo Ter=E4s wrote:
>
> I would not consider this a new feature. It just makes pfkey
> act consistently. If you don't want it supported, it'd make
> more sense to not #define SADB_X_EXT_NAT_T_OA and drop all of
> the verification code already present than to silently
> ignore it. Make kernel return an error if some tried using it.
>=20
> Now you give impression that it's supported but you just drop
> it silently.

Timo I think we need to draw a line somewhere, otherwise we're
just providing life support to an interface that should die.

IMO if there is a bug in pfkey that breaks a major existing
app (i.e., ipsec-tools/racoon), then we should fix that.

But if it's something that the existing apps don't care about
then no we need to just stop extending the interface.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
