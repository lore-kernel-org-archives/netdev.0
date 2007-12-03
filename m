From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] sungem: fix napi regression with reset work
Date: Mon, 03 Dec 2007 10:29:22 +0100
Message-ID: <1196674162.6060.8.camel@johannes.berg>
References: <1196107328.8459.8.camel@johannes.berg>
	 <20071129105755.GF22537@gondor.apana.org.au>
	 (sfid-20071129_110000_566221_80E03D19)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-W86VBNMdrOcK5rN7LKkt"
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:58168 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754384AbXLCKgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 05:36:19 -0500
In-Reply-To: <20071129105755.GF22537@gondor.apana.org.au> (sfid-20071129_110000_566221_80E03D19)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-W86VBNMdrOcK5rN7LKkt
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Thu, 2007-11-29 at 21:57 +1100, Herbert Xu wrote:
> On Mon, Nov 26, 2007 at 09:02:08PM +0100, Johannes Berg wrote:
> > sungem's gem_reset_task() will unconditionally try to disable NAPI even
> > when it's called while the interface is not operating and hence the NAP=
I
> > struct isn't enabled. Make napi_disable() depend on gp->running.
> >=20
> > Also removes a superfluous test of gp->running in the same function.
> >=20
> > Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
>=20
> Patch applied to net-2.6.  Thanks Johannes!

Thanks. I just noticed that I made a mistake in the patch description,
it should read "Make napi_disable() depend on gp->opened". I don't think
it matters much but wanted to at least mention it.

johannes

--=-W86VBNMdrOcK5rN7LKkt
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR1PMcaVg1VMiehFYAQLl1Q//Q/pOCzA/FPM3c/zSAKQhJknRiv+dSLtl
uRpZDDq+L5u845YzC4MVQ4OzbO458NDlbPCw/trY2bbds+mYQwTJibqqxPlUsEeA
XPnxbX0A+BwztV33G1p3DxqLmbCa4B7heZrxzkRAjOEI+OQIqo8R5I0jIWv8hrkT
dumYP86glMghM4pyjIn5mmSUiNHBRX03gK0ExsuM9XV8BJ5oNub9E4toD/4RU6o0
Umtdg4WAyOsVH4v13brsTOosWESsHZzgwDONWeLLBhDbQJ8DPMghznE5Tv0Ee5l1
FvnyAvk1AWdoMbLQ6YkRKpT6256py6vK9HbhdLF7YRz8hXllFq2sJEj3B3Nh6P7n
QqcOwzYc/+zV7Q2J/y/ZSl4Ch7hOVsM5APlnZwjES2y1j3NOzA5XBKnmxG+wRbe9
D11TdJFtJR9jgTxHZxfehix+WeLje/wdOw+4Wev/P+bWNFOYpLCVsxzbsYDo7kDr
bMpYEIqKaeuEckFV44Yc5iKBkuiF9FaPQyh7eng95ivUxtM7CxNtaiEiUSI/bD3Y
Ub1/r9bQ2Z71Y0MTeC23ntddh3QK6oYqVuQmTqiV++0vHVMMohKjxXu/mk8wr3Lj
q9wGigUIeMhEOgfM0N8ilef2PDXCu+//hyDVPuo4hgJ93aISCXO+wqTQuzyTfm4r
KdWmZWRaZLw=
=Q3qh
-----END PGP SIGNATURE-----

--=-W86VBNMdrOcK5rN7LKkt--

