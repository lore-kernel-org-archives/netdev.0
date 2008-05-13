From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: mac80211 truesize bugs
Date: Tue, 13 May 2008 22:59:16 +0200
Message-ID: <1210712356.4279.22.camel@johannes.berg>
References: <20080502.163334.148944203.davem@davemloft.net>
	 <1209807477.3987.9.camel@johannes.berg>
	 <1209824720.1475.6.camel@johannes.berg>
	 <20080512.201751.114868351.davem@davemloft.net>
	 <20080513203906.GB20269@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-DIUwSI2XblUv5q4YARDa"
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	mb@bu3sch.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:41063 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759496AbYEMVA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 17:00:29 -0400
In-Reply-To: <20080513203906.GB20269@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-DIUwSI2XblUv5q4YARDa
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2008-05-13 at 16:39 -0400, John W. Linville wrote:
> On Mon, May 12, 2008 at 08:17:51PM -0700, David Miller wrote:
>=20
> > Based upon them I will adjust LL_MAX_HEADER as follows:
>=20
> > @@ -93,14 +93,16 @@ struct wireless_dev;
> >   *	used.
> >   */
> >  =20
> > -#if !defined(CONFIG_AX25) && !defined(CONFIG_AX25_MODULE) && !defined(=
CONFIG_TR)
> > -#define LL_MAX_HEADER	32
> > +#if defined(CONFIG_WLAN_80211) || defined(CONFIG_AX25) || defined(CONF=
IG_AX25_MODULE)
>=20
> Is WLAN_80211 really the right symbol here?  It applies to more than
> just mac80211, and I doubt if full MAC devices need higher values.
> It seems like MAC80211 would be the right symbol to add.

Most fullmac devices also need some space, whether they do things that
way or not is a completely different thing, the ieee80211 stack for
example copies every packet into a new skb anyway.

johannes

--=-DIUwSI2XblUv5q4YARDa
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASCoBI6Vg1VMiehFYAQLXYA//bCtWG+fbBk8tkUcmme2JAx5PeMVg3ekN
myRzq/ZPYi/m5MVGECHBRwc09ePZhJlH1oXdZu5TWt3OGPJpCgL+OoQnB5DCy66d
SDB8nExX0Mh9UniGrv3jC99cswrLE25AoPLoM+PDdVlWe3NpAR/+8pqorR3su+Bh
NKNALvphmmOCqhq/oKKAva9rOURfkD3Fe6veGgB8vnm1OLce8MV4iqbBGXgcEAZS
zbok1auNs/DLZRMpBtziVHpZjQ+adS/KoZ6UzmaFiHyretCfDnw1w/i6ZYlX4qGs
0QiOfCI7UMosI8i7WrUYE2/gqPMqEd0G+HHLSLdpQktPAXpOnRjv7zs8lbH/Ox7J
feARHFeZReuHQN+nKN62HuGfJCzD6EM8TAtxa6UB0GpbGklwCfNsYVHaUth1Poix
/t7il0iZkZ0Q+WSZhCnDiDGYjuS1MBuG3OAXHa1uiiSq+cQS/Xp1r20pHjokxX/1
RvPB+Z6F15Bthp3ji75TNKtGDNLghU0N1QuWRmUSQwzld9YnpKYpWQFhXJKJKUgR
ct16M6IXSs7OSaquo60mEbZu1Ci1D5E/qNIjrfEnuJey0x2i5cgDOg4PKOpLRmCn
MVg0qPZTgVqgFfcv3bqZyo2oRSevw/xD8UrM0qt7VInP4IRC9+TrMWBmEJsqb+Nx
XyfaZ89Qhjg=
=I6iQ
-----END PGP SIGNATURE-----

--=-DIUwSI2XblUv5q4YARDa--

