From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net/can:  rename peak_usb dump_mem function
Date: Mon, 03 Sep 2012 11:02:19 +0200
Message-ID: <5044721B.8030507@pengutronix.de>
References: <1346577700-8156-1-git-send-email-geert@linux-m68k.org> <504393A7.8040007@xenotime.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig53A119B1730FC3E6BD971FDC"
Cc: netdev@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stephane Grosjean <s.grosjean@peak-system.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <504393A7.8040007@xenotime.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig53A119B1730FC3E6BD971FDC
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/02/2012 07:13 PM, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@xenotime.net>
>=20
> Rename generic-sounding function dump_mem() to pcan_dump_mem()
> so that it does not conflict with the dump_mem() function in
> arch/sh/include/asm/kdebug.h.
>=20
> drivers/net/can/usb/peak_usb/pcan_usb_core.c: error: conflicting types =
for 'dump_mem':  =3D> 56:6
> drivers/net/can/usb/peak_usb/pcan_usb_core.h: error: conflicting types =
for 'dump_mem':  =3D> 134:6
>=20
> Not tested.

:) I've converted the users of peak's dump_mem() function, too. Now it
compiles. Should this go into v3.6, or is v3.7 early enough?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig53A119B1730FC3E6BD971FDC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iEYEARECAAYFAlBEchsACgkQjTAFq1RaXHOxvgCeMgKpXKqbuvwjk5E1ztkdi2L0
bVgAoIVvPIsepqwIFp3CqGovX8OEWUu7
=s4ws
-----END PGP SIGNATURE-----

--------------enig53A119B1730FC3E6BD971FDC--
