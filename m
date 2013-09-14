From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH net 0/3] SLCAN/SLIP fixes and performance
Date: Sat, 14 Sep 2013 12:45:56 +0200
Message-ID: <52343E64.1050207@pengutronix.de>
References: <1379093833-4949-1-git-send-email-nautsch2@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="7dqrSudOtSmMtOmTLcuDXcATt4OxSn1NS"
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andre Naujoks <nautsch2@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1379093833-4949-1-git-send-email-nautsch2@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--7dqrSudOtSmMtOmTLcuDXcATt4OxSn1NS
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/13/2013 07:37 PM, Andre Naujoks wrote:
> Hi Dave,
>=20
> these are some loosely related patches, that fix an ancient locking pro=
blem in
> the slip and slcan drivers, add general ASCII-HEX to bin functions for
> uppercase ASCII, fix the handling of CAN RTR frames in the slcan driver=


Can you get an Acked-by for the ASCII-HEX functions from the appropriate
maintainer?

> and increase the performance for the slcan driver.
>=20
> As these patches mainly contain fixes for the slip/slcan drivers that r=
equire
> a tty layer fix included in 3.11, I would suggest to get the patches in=
 via
> the net tree for the 3.12 cycle. They should apply properly on the late=
st net
> and mainline tree.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--7dqrSudOtSmMtOmTLcuDXcATt4OxSn1NS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlI0PmgACgkQjTAFq1RaXHOwTwCaA0JPqw/msDkE8L/8JjVlhIX6
ReQAn0FEnSiAje51pFF4OHBJa8FPjaNU
=aZNV
-----END PGP SIGNATURE-----

--7dqrSudOtSmMtOmTLcuDXcATt4OxSn1NS--
