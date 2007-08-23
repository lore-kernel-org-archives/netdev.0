From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Thu, 23 Aug 2007 18:12:00 +0200
Message-ID: <1187885520.22725.4.camel@johannes.berg>
References: <1187808408.4314.15.camel@johannes.berg>
	 <1187884912.32738.24.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-oYs/ggMkV7t5Wq5dYxtN"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:46342 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763427AbXHWQLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 12:11:22 -0400
In-Reply-To: <1187884912.32738.24.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-oYs/ggMkV7t5Wq5dYxtN
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-08-23 at 09:01 -0700, Joe Perches wrote:
> There are also several different uses of the equivalent of
>=20
> 	printk("%02x",addr[0])
> 	for (i=3D1; i<6; i++)
> 		printk(":%02x",addr[i]);
>=20
> to print an ethernet MAC address.

Hm. I didn't know that, I can go through in a later patch if desired.

> http://www.uwsg.iu.edu/hypermail/linux/net/0602.1/0002.html
>=20
> As not all device MAC addresses are 6 bytes, colon separated,
> perhaps an appropriate ethernet/tr MAC designation is EUI48.
>=20
> http://standards.ieee.org/regauth/oui/tutorials/EUI48.html

Practically, however, nobody is going to even find macros named
EUI48_FMT/EUI48_ARG, would they? I don't much care, but I find it rather
unsatisfying that both wireless code bases define these macros.

johannes

--=-oYs/ggMkV7t5Wq5dYxtN
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGzbHQ/ETPhpq3jKURAlQSAJ0aVF9RPGFlyhJ+faV5rRbKC46PzwCfU4ha
WpECdPHoZRKml/w5XOCxNVU=
=WlGY
-----END PGP SIGNATURE-----

--=-oYs/ggMkV7t5Wq5dYxtN--

