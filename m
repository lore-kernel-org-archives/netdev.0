From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: [PATCH 4/6] net neighbour: convert to RCU
Date: Tue, 29 Aug 2006 20:34:01 +0200
Message-ID: <1156876442.25085.2.camel@localhost.localdomain>
References: <20060828230748.827712918@localhost.localdomain>
	 <20060828230915.587544687@localhost.localdomain>
	 <20060829152816.GA24283@ms2.inr.ac.ru>
	 <20060829112204.0cf5e866@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-EJk6O4TiZFO1Ob2d1v12"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailfront1.citynet.nu ([217.10.96.36]:37533 "EHLO
	mailfront1.citynet.nu") by vger.kernel.org with ESMTP
	id S965254AbWH2SeJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 14:34:09 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060829112204.0cf5e866@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-EJk6O4TiZFO1Ob2d1v12
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2006-08-29 at 11:22 -0700, Stephen Hemminger wrote:

> > Probably, you should do atomic_inc_and_test() here and restart lookup,
> > if it fails.
> >=20
> > Alexey
>=20
> atomic_inc_and_test is true iff result is zero, so that won't work.

Wouldn't atomic_inc_not_zero() do what you want?

--=20
/Martin

--=-EJk6O4TiZFO1Ob2d1v12
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQBE9IiZWm2vlfa207ERAux+AJ4hCN/ae3hNy8ow/6CluZEYSLlTigCgrx+s
4Lh87hYe8HwhzKKuC6VRIII=
=qYeJ
-----END PGP SIGNATURE-----

--=-EJk6O4TiZFO1Ob2d1v12--

