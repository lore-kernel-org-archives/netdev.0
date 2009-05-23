From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: skbuff: Move new code into __copy_skb_header
Date: Sat, 23 May 2009 10:19:12 +0200
Message-ID: <1243066753.4606.39.camel@johannes.local>
References: <20090523081137.GA12567@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-Dk3KXUXKfeOZaMEMb/no"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul Moore <paul.moore@hp.com>,
	Sujith <Sujith.Manoharan@atheros.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:56980 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751282AbZEWITX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 May 2009 04:19:23 -0400
In-Reply-To: <20090523081137.GA12567@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Dk3KXUXKfeOZaMEMb/no
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2009-05-23 at 18:11 +1000, Herbert Xu wrote:

> skbuff: Move new __skb_clone code into __copy_skb_header
>=20
> It seems that people just keep on adding stuff to __skb_clone
> instead __copy_skb_header.  This is wrong as it means your brand-new
> attributes won't always get copied as you intended.
>=20
> This patch moves them to the right place, and adds a comment to
> prevent this from happening again.

Oops, thanks. But on the positive side, I'm getting rid of skb->requeue
again anyway :)

johannes


--=-Dk3KXUXKfeOZaMEMb/no
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKF7F7AAoJEODzc/N7+Qmal7cQAL2Um/CGM+RG7QWuApCBpP67
Q8T4/vnSHAB62a2yvxXPwzH2PvMGk76YsWAmTaEEbDtO80pp53MkyeD1GQpMT2ZL
ZBxMAfLYMzi0oDaTBD0BfezKOZL2wVWmyQY7HaPSSLNfJmTKwOb9/l3JURf77acd
eBiKYeqEeAygIRe1A7AE3dhfXVzmXalUAufjcr1SmnaletCb1aCBOzmBx3xCCRXe
wtSgpSedZFmIiDEaVephSAAtBsn6rkr4+H5Ovv+hgyOIfe6XKUUTBKdpCbozcZMG
8rbwnp/acX4kqeqaKmAZLYNFiNayT3LWj7g3uoXCXahWXK6Aj6dZBpu6lZRZRN5k
SkDisYUDZOcVteAw0u+JX9BSEoYCZC4jERHS7k1seKk25UjRt9si8IaZ1rkyyTV0
7n4wNrVkwAR6DYk5f4WqlI+0BeuQpY+b1Yan36FuqzBQzPfyKQTX9zN4M3kNhTrH
jHqc98vXpqjxyB5mCO2c8zQRRUvGlVW5mo2/hBTy9DWOn4uVSZGcpTAvr+h9lxuy
d7RpKLd2P6Mlb4URAfBku0qY1G8gQkpSPjuJ4qTTzskjjDqpDf+C3Cb9G4et4KZY
5W11Do4iOV5z+kLSDce/rtK/Bdz3YHKYiJJ6R70/jZDnCA7tB/4IbBr9Dswn/P8f
nD5jberr05SvQJTkQh2g
=qtsR
-----END PGP SIGNATURE-----

--=-Dk3KXUXKfeOZaMEMb/no--

