From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: c_can_pci: limit compilation to archs with clock
 support
Date: Wed, 20 Jun 2012 12:10:41 +0200
Message-ID: <4FE1A1A1.3000105@pengutronix.de>
References: <1340185688-9454-1-git-send-email-mkl@pengutronix.de> <20120620.025452.2203668280120884694.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigDAFE57454A726CCA8AE415D7"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	federico.vaga@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20120620.025452.2203668280120884694.davem@davemloft.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigDAFE57454A726CCA8AE415D7
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 06/20/2012 11:54 AM, David Miller wrote:
> From: Marc Kleine-Budde <mkl@pengutronix.de>
> Date: Wed, 20 Jun 2012 11:48:08 +0200
>=20
>> In commit:
>>
>>   5b92da0 c_can_pci: generic module for C_CAN/D_CAN on PCI
>>
>> the c_can_pci driver has been added. It uses clk_*() functions
>> unconditionally, resulting in a link error on archs without
>> clock support. This patch adds a "depends on HAVE_CLK" to the
>> Kconfig symbol.
>=20
> This is an unreasonable change and I just explained why in my email to
> Frederico, did you not see it?

I send that mail before I received Frederico's and your Mail.

> He says that this driver was only tested on an architecture that
> currently doesn't even have clock support in any existing tree, and
> therefore completely relies upon local changes they have to add clock
> support to that platform.
>=20
> Which means you're change is restricting compilation of this driver to
> platforms the driver was never, ever, tested on.
>=20
> Can you see what a complete joke this is?

I think we finally can see the big picture now; I'm preparing a patch
which removes the clk_*() functions.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigDAFE57454A726CCA8AE415D7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEUEARECAAYFAk/hoaIACgkQjTAFq1RaXHNS6ACYvKNWC+WfCv+TYsAWA7i4hqfQ
ZgCfeTJVgZWce7ai7Dm5L3pItaIs0SM=
=MNwO
-----END PGP SIGNATURE-----

--------------enigDAFE57454A726CCA8AE415D7--
