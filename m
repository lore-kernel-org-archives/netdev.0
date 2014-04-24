From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: pull-request: can 2014-04-24
Date: Fri, 25 Apr 2014 00:04:17 +0200
Message-ID: <53598A61.6010904@pengutronix.de>
References: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="V9q4VPhXsi05rdpGF6jLKPpNeuwAi4Adu"
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--V9q4VPhXsi05rdpGF6jLKPpNeuwAi4Adu
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 04/25/2014 12:00 AM, Marc Kleine-Budde wrote:
> Hello David,
>=20
> this is a pull request for net/master, for the v3.15 release cycle, con=
sisting
> of 26 patches.
>=20
> Thomas Gleixner contributes 21 patches for the c_can driver, which addr=
ess
> several shortcomings in the driver like hardware initialisation, concur=
rency,
> message ordering and poor performance. Two patches Oliver Hartkopp, one=
 adds a
> missing lock to the sja1000_isa driver, the other one fixes the return =
value in
> the generic bit time configuration function. And finally a patch by Ale=
xander
> Stein, that fixes the slcan driver to use the correct spinlock variant.=


To make it 26 patches, I forgot to mention, Wolfgang Grandegger patch
for the c_can_pci driver, which enables the bus master only for MSI and
a patch by Wolfram Sang, which converts the 'instance' in the c_can
driver to the proper type.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--V9q4VPhXsi05rdpGF6jLKPpNeuwAi4Adu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlNZimQACgkQjTAFq1RaXHNdlwCfYSolm8OxHI1zMcyYLzVO54bE
zUwAoIiRnwyMcDIsC6JheGUde+R5oJjg
=Kylq
-----END PGP SIGNATURE-----

--V9q4VPhXsi05rdpGF6jLKPpNeuwAi4Adu--
