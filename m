From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: NULL pointer dereference in sysfs_hash_and_remove()
Date: Tue, 14 Oct 2003 20:50:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1066157445.740.2.camel@tux.rsn.bth.se>
References: <1065220892.31749.39.camel@tux.rsn.bth.se>
	 <20031013163200.43e5d1bf.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-0aUiYSDu5jwesMQwEtGO"
Cc: Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031013163200.43e5d1bf.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-0aUiYSDu5jwesMQwEtGO
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2003-10-14 at 01:32, Stephen Hemminger wrote:
> On Sat, 04 Oct 2003 00:41:32 +0200
> Martin Josefsson <gandalf@wlug.westbo.se> wrote:
>=20
> > Hi
> >=20
> > I compiled 2.6.0-test6 and ran it on a laptop with cardbus.
> > I have an Xircom NIC and if I remove it during operation I get the bug
> > below.
> >=20
> > I have yenta_socket and xircom_cb loaded as modules.
>=20
>=20
> The driver was setting the statistics pointer after registration had occu=
rred,
> so on unregister the network code was removing a non-existent sysfs direc=
tory.
>=20
> Try this please.

I've applied this patch and=20
"[PATCH] sysfs -- don't crash if removing non-existant attribute group"
and now it works great.

Thanks.

--=20
/Martin

--=-0aUiYSDu5jwesMQwEtGO
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQA/jEWFWm2vlfa207ERAhF8AKCAFiUOZUmcxjEvEmpw9uA7w+nk5wCdEwG+
xk/Ch/NO8NUa/06vTa1S/yA=
=g+ip
-----END PGP SIGNATURE-----

--=-0aUiYSDu5jwesMQwEtGO--
