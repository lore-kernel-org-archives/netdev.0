From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v2 0/8] net: extend ethtool link mode bitmaps
 to 48 bits
Date: Tue, 06 Jan 2015 23:08:39 +0000
Message-ID: <1420585719.2327.3.camel@decadent.org.uk>
References: <1420512850-24699-1-git-send-email-ddecotig@gmail.com>
	 <54ABE991.3040107@mellanox.com>
	 <20150106.172918.70204012105519766.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tK3v0/BiFej0tuURuXLj"
Cc: amirv@mellanox.com, ddecotig@gmail.com, f.fainelli@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org, saeedm@mellanox.com, decot@googlers.com,
	jasowang@redhat.com, mst@redhat.com, herbert@gondor.apana.org.au,
	viro@zeniv.linux.org.uk, yamato@redhat.com, xii@google.com,
	nhorman@tuxdriver.com, xiyou.wangcong@gmail.com, fbl@redhat.com,
	teg@jklm.no, jiri@resnulli.us, vyasevic@redhat.com,
	ebiederm@xmission.com, VenkatKumar.Duvvuru@Emulex.Com,
	_govind@gmx.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39808 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751796AbbAFXIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 18:08:51 -0500
In-Reply-To: <20150106.172918.70204012105519766.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-tK3v0/BiFej0tuURuXLj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-01-06 at 17:29 -0500, David Miller wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Tue, 6 Jan 2015 15:56:33 +0200
>=20
> > Mellanox is about to release next month a driver for a new NIC, with 3
> > new speeds * few link modes for each + new link modes for 10G.
> > It seems that we will need to consume almost all the new bits.
>=20
> This tells me that the approach to this problem needs to be rethought.
>=20
> Maybe we just need to bite the bullet and make a new ETHTOOL_GSET_2
> and ETHTOOL_SSET_2 or whatever you want to name them.
>=20
> Then we can define a completely new structure, with 64-bit bitmaps
> for link modes or whatever.  The ethtool_op callbacks work using
> this structure, and only the net/core/ethtool.c code knows about
> the older structure and translates to/from for ETHTOOL_{GSET,SSET}.

Agreed.

Ben.

--=20
Ben Hutchings
This sentence contradicts itself - no actually it doesn't.

--=-tK3v0/BiFej0tuURuXLj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVKxq9+e/yOyVhhEJAQobKA//U626QfSZVXVm5NEKEDqem9Q5+ymyErY3
cl1bHBoUt6CGWuv6CVwbEQ5isCmxexwFxe5TMiLa0BjY+4v2uc14vdePJ0mklSi1
9x/iwevjtv7tqMUGrJd89F5DY/eXwFq1m4qVULqJd7WULWTJJoptXT87f0/DsF9V
nYom4gY0PRelYtAQswuqFnjKpUZQ+oxX7lNHooWFjRvXTgBBj4DaFpDntoYmAb4n
/JAV2FPy2H4Qvzuo6f/ElRIb8KE8BTlR1Z61qdBBW2ANrBYsKVgpzlE8HGS6KJv8
XSSvwDb/jQyISbvVGC5eFoD1Tguz8X3Ri25YayXJFIgAw+IoGKJRF7lTeN1pb77j
hbyCRd4x+4mlc1Uo368BioU5Ej7ncfIQ732NPBYc/SJeUWQbBUSNDEfxAWmdt2ev
+Te1vUJgpZYuGqYWzlICmklaixgwQYDRr9ga6d7IE6Cbnus/HyhNvES+NYbeVEq2
VxknvQH4Www2NiAU7su888JI5iz5GJlit6B4zVYkdkV0XGkAm7az36H9zAIZJ5LT
hJLqfmADGYaguC9rWAASZ0YDXjYaexB04OCmJie6uDlcT8mcc+g4mqsw+kaHo3SI
6CR11qdu9M65L5M2Z0YTzDerETzffCHoPiCMA7q5pch2iqs88I4FkzHvizR08gFF
1rPu0mquyBI=
=TwXQ
-----END PGP SIGNATURE-----

--=-tK3v0/BiFej0tuURuXLj--
