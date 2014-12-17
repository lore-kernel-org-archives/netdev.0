From: Richard Laager <rlaager@wiktel.com>
Subject: Re: Fw: [Bug 82471] New: net/core/dev.c skb_war_bad_offload
Date: Wed, 17 Dec 2014 08:52:08 -0600
Message-ID: <1418827928.4489.5.camel@watermelon.coderich.net>
References: <1418805852.5277.25.camel@watermelon.coderich.net>
	 <20141217095552.GB27966@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-/pS/qxs/cHEJGxgHkGtK"
Cc: netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.wiktel.com ([69.89.207.151]:49303 "EHLO smtp1.wiktel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750905AbaLQOwf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2014 09:52:35 -0500
In-Reply-To: <20141217095552.GB27966@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/pS/qxs/cHEJGxgHkGtK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-12-17 at 10:55 +0100, Michal Kubecek wrote:
> Would it be possible that the kernel you are using has
>=20
>   da08143b8520 ("vlan: more careful checksum features handling")
>=20
> (and possibly also a9b3ace44c7d and 3625920b62c3) but not
>=20
>   db115037bb57 ("net: fix checksum features handling in netif_skb_feature=
s()")

Ubuntu's 3.13.0 has none of these changes.
Ubuntu's 3.16.0 has all four changes.

The problem occurs on both kernels.

--=20
Richard

--=-/pS/qxs/cHEJGxgHkGtK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABCAAGBQJUkZiYAAoJEA/9MsdVF+JS/ZoH/0vM18wYovHeRvWRfy32uuAG
pUdGs6ILLAWeuowgI9aqfo4loGhUubMA68pstIPsMdIjsAJJGt5WA6paPlVT8Jtz
Pq5cH0tv90XMcdJxY9A7wjZsocP9j2/VotXvh98YoimZvAB6YDMcXp47+gqoxkji
XnDDeJZPmdpvUMJZSOwYdDMzn8GPZawDR9Mw3haBqjLoLpPrF6sHClFWkTgBoW8Z
YEJCbNVp03KAMA0JWcrFIJXZdZwSp+v0bv/e9gH00L+HUZZ7uLFZ3pPYDtbZRgc3
NuD1Pdk5vUOYgKOb6pM8EtY7jL/gI55xsOc0x5jwmabMk26xXb5IeMkJiWHaQKM=
=Rrdi
-----END PGP SIGNATURE-----

--=-/pS/qxs/cHEJGxgHkGtK--
