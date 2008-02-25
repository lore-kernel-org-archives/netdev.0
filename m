From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Mon, 25 Feb 2008 18:29:00 +0100
Message-ID: <1203960540.13162.124.camel@johannes.berg>
References: <1203589042.17534.145.camel@johannes.berg>
	 <1203616486.7181.269.camel@localhost> <47BDBC23.5080007@trash.net>
	 <20080223.200202.255773165.davem@davemloft.net>
	 <1203933228.13162.58.camel@johannes.berg>
	 <1203958429.19319.273.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-jF0OP5ubMvwQfX/7vEm5"
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	harvey.harrison@gmail.com, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:54460 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165AbYBYR3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 12:29:12 -0500
In-Reply-To: <1203958429.19319.273.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jF0OP5ubMvwQfX/7vEm5
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > Maybe we should just add a new printf modifier like %M for MAC
> > addresses? Then we could use sprintf, snprintf, printk and whatever we
> > please without any of the macro stuff...
>=20
> Could gcc validate the printf %M arguments?

No, but it won't barf on it either, it silently ignores unknown stuff.

> Another possibility without changing printf argument validation
> is to use a MAC_FMT macro in place of "%s"
>=20
> #ifdef CONFIG_INLINE_MAC

Yes, but the argument was that in some debugging cases these things are
in the fast path even when debugging is turned off, so to not have  them
there would force you to always turn this config ON which defeats the
point.

johannes

--=-jF0OP5ubMvwQfX/7vEm5
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR8L626Vg1VMiehFYAQLfHA/8Crp9otAdBCV+4fl8tcSmN9Kb/E85C6Yr
RvIQYa+dTSgkHR9J4/LVpBG3YW77HvC9mtc/tYFWhCN/j+X9ldsGuPQ5wBARJgjy
el7Hvpxt+TfseOSlw3Dn110DE3eTM06vV08J5NOvXJ5nWdMlXNjj6m8E3ms4d/3a
Fwvi75f0hHnIfAztX2RCggmkWqNjPIbO3H4rYw+WOmKClAHa+NUZgaPLfO8nYb9+
Y+Sr8g3VVLyGAv7VENuoDEAOjkMFttJ8nU2BMsdJWfxz+RJJmcjjtf0wMJzOv94a
h+4CV7HstXCVPQ/IpxBYVn7PmQPKhJU0UXZerQWJ1TzTqHmDcAK4Ex2WIcdDdJuH
p/jYOmCTJxGNZg516ag5VlVdcZWyN6+3oFQFPpYHojvLXpFQROKocm+LSYUCvMv/
eJwQNVgX6D1N3j+BgAmC0we8B6dteqIPIjTriledQ+oCtCmzbmTg4+pDqMd0rPcC
UK/S/HdB/8G2wfxa7FuJ0s/lqLPVPs0/Er19E1ENLz13hnZ9MCklis1esq43KGBL
evAkZOUbf9IANFprVgaHT1J+fWKKqxHAcI0QfAe1cvGVNR86JKTq/hnuBp5SDqtD
33Pg/ULu/gH1eVk2eiImRAdI4sVZc7+LWkYQnhcmvFUqBKSA1iauBHiNNohKhGHS
1A5OHbZhljA=
=KWQi
-----END PGP SIGNATURE-----

--=-jF0OP5ubMvwQfX/7vEm5--

