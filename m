From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [can-next PATCH 1/1] net: can: c_can_platform: Use devm_ioremap
 instead of devm_ioremap_resource.
Date: Fri, 25 Jul 2014 09:38:27 +0200
Message-ID: <53D20973.108@pengutronix.de>
References: <1406269181-4092-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Bs7ALppi4kiEu84CrsRcE8GOLSHgvm45q"
Cc: Pavel Machek <pavel@denx.de>, Thor Thayer <tthayer@altera.com>,
	Prabhakar Lad <prabhakar.csengg@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Wolfram Sang <wsa@sang-engineering.com>,
	Chen Gang <gang.chen@asianux.com>,
	George Cherian <george.cherian@ti.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1406269181-4092-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Bs7ALppi4kiEu84CrsRcE8GOLSHgvm45q
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 07/25/2014 08:19 AM, Mugunthan V N wrote:
> From: George Cherian <george.cherian@ti.com>
>=20
> The raminit register is shared register for both can0 and can1.
> Using devm_ioremap_resource fails the mapping for can1 interface
> leading to a non functional can interface.
>=20
> Signed-off-by: George Cherian <george.cherian@ti.com>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied to can, I've adjusted the commit message a bit, mentioning the
patch, that introduced the regression.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Bs7ALppi4kiEu84CrsRcE8GOLSHgvm45q
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlPSCXMACgkQjTAFq1RaXHNc/wCfXz37FNJ2pEd3/dGrldnkVLLu
YhwAn2hoEv8HGjBWZnZRxC9lIk1X67qR
=oKyn
-----END PGP SIGNATURE-----

--Bs7ALppi4kiEu84CrsRcE8GOLSHgvm45q--
