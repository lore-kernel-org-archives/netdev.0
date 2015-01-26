From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v6 0/7] can: kvaser_usb: Leaf bugfixes and USBCan-II support
Date: Mon, 26 Jan 2015 11:07:22 +0100
Message-ID: <54C611DA.8050500@pengutronix.de>
References: <20141223154654.GB6460@vivalin-002> <20150126051755.GA3014@Darwish.PC>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="IhcF0iCl1oeMF2mbQfi54CMViQpiSU1HD"
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andri Yngvason <andri.yngvason@marel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150126051755.GA3014@Darwish.PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--IhcF0iCl1oeMF2mbQfi54CMViQpiSU1HD
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/26/2015 06:17 AM, Ahmed S. Darwish wrote:
> Hi!
>=20
> This is an updated patch series for the Kvaser CAN/USB devices:
>=20
> 1- Extra patches are now added to the series. Most importantly
> patch #1 which fixes a critical `sleep in atomic context' bug
> in the current upstream driver. Patch #2 fixes a corruption in
> the kernel logs, also affecting current upstream driver. Patch
> #4 was originally USBCan-II only, but since it's a generic fix,
> it's now retrofitted to the Leaf-only upstream driver first.
>=20
> 2- The series has been re-organized so that patches #1 -> #4
> inclusive can go to linux-can/origin, while the rest can move
> to -next.
>=20
> 3- There are some important updates regarding the USBCan-II
> error counters, and how really erratic their heaviour is. All
> the new details are covered at the bottom of this URL:
>=20
> 	http://article.gmane.org/gmane.linux.can/7481
>=20
> 4- Attached below is the new candump traces. Now
> `back-to-error-active' states appear _if_ the hardware was
> kind enough and decreased the error counters appropriately.
> The earlier code did not recognize the error counters going
> down, thus the `back-to-error-active' transitions did not
> appear.

For patches 5-7 I'm waiting for an Acked by Andri.

=2E..and we have to wait until Patches 1-4 will show up on net-next/maste=
r.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--IhcF0iCl1oeMF2mbQfi54CMViQpiSU1HD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJUxhHdAAoJECte4hHFiupUOdUQAKv/8q2FPc1dSy1NTyKH5DOQ
Oj9cy6lkZzhbLxGP4fhAlbSrxvVFwEF4iOrlzoUJYH0l7ckh3cp97vYvUR3mCiPy
WuqkVJecB5pef/00PkA0GtITWLXZe6XbdaTEqhEUkcNA9OElgrRQtfLQs3ukYThV
UQd/VcPBxC/rmQet5kpb27GgPsz+w3auGn3W6Zgoz2zjhpCgEjOFhDl/TSUOeTDs
ira2uiztJXBnnAD1jFWj9udmRY8wQE9VLcXFDM7jRD2fElL8wA7N5Z6P3T4QfIHB
ILnISjjl720MOpkFxM2mX/T4ZOyXKr1bFh8LOkwKpKvBsfEAXPcpSnCrs0qWl99F
FqrONeM5Fi/fB6aV7NJst4rOQxEImCvZAgqxcgbtGlXrzN2Y6rwdJ70Xo/naore2
C4OsLEM1JZUrqMybqhthqhqCQGyk1ibnoJBOmntiPaHNtuToPWE5IghuEDdibT2t
H3qH9r+Z1/lX3kqJZx1v3uQpTJ2HrkAnpzfSdcx3M3oB4QQNMfJciWUUcJs1EPEi
20H4hX5XEzq+KKKXR14ky5CFBk0IBhHB0CRYD8yJte4KAF4XqknWkiFe9596sX/A
V/uUPdPAfDAxYmiVcC6M9A7poCihzdN+8QmCDyHy6uZizgC5MMdxCp4RjOuwOjEo
0Kos9VqJO1A4IynMQcSs
=/6es
-----END PGP SIGNATURE-----

--IhcF0iCl1oeMF2mbQfi54CMViQpiSU1HD--
