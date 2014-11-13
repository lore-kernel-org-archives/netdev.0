From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 4/8] net: can: c_can: Add syscon/regmap RAMINIT mechanism
Date: Thu, 13 Nov 2014 13:58:48 +0100
Message-ID: <5464AB08.3020707@pengutronix.de>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-5-git-send-email-rogerq@ti.com> <54649153.409@pengutronix.de> <54649F66.8090305@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="uEV2qNAmkWoUMAPn3qV0UukWc6QEnsX9n"
Cc: wsa@the-dreams.de, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, wg@grandegger.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <54649F66.8090305@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--uEV2qNAmkWoUMAPn3qV0UukWc6QEnsX9n
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/13/2014 01:09 PM, Roger Quadros wrote:
>> What about the existing device trees that don't have the syscon-ramini=
t
>> phandle? We can either keep the existing init routines or create regma=
p
>> in the platform driver an use the new ones.
>=20
> There is only one user
> arch/arm/boot/dts/am33xx.dtsi
>=20
> The can nodes are disabled there and no other board file is enabling th=
at node.
> So there is no breakage as such and not worth the hassle to maintain th=
e old routine.
>=20
> I will be sending the corresponding dts changes today which Tony will t=
ake as we don't see
> any DT binding changes.

Alright then (I'll give your email to $CUSTOMERS complaining ;) ), this
whole series will go into 3.19.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--uEV2qNAmkWoUMAPn3qV0UukWc6QEnsX9n
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZKsIAAoJECte4hHFiupUGHkP/2Txp1x7vxII4Vjp4CW4hJSy
VxyomtFB3InfUn0TO50Cwn7AzJzX9SQzKeZV/U7d+BTjBRoRS5QIvp1m3MZV4Ich
ji07NjW3Fj/n7YhYhaUMXF8xf5Eh4uinUDboIAVI2nXT4+ERoRHvR1Pj1553vRVq
Ceh9RN0n0xd58j2/8uqiRS4iUQmf73VeWyMqmOQzEEDL9uOu0KOxgR9Gxm96CpHv
cmUNrMumMGMYaGEJrczNaWh8C0AX62LJsERGWsq4EwMLyBEM6tNauGmCIVMBqNJi
K2BH+sFZLgo9vsUJy54x1AWttEaZo5H7sxEogWU0DKqJAs1Ji/5bvS6slbU5poDH
sG+16ReEuwW2jXTaTrNtObYBJRIvkJ5v78Rl0O+DhlPeeRaezyPthcHL4RysIhRI
ogE5rON0ABtoCfzKKpp19vBR0yqHryrYPGufP0QtTShhFds4CGjP/v7yVVYBqgw6
qYVdqBBz3XwnAkLjNTGEi/t1ObOiwAiRFXIaHn/IgW9WoRNi8yXoZ5wojSaDHJ04
Nj7yIgSFQRR5YBjU3d7gyG+d3aDrVD5lWYa8MnYsP+pUV755w7XBxksDdmH0oqkv
XSf2XsbHezVQu/oXflrqz9Re0whypqANAldp+ZaLqutX9Rk+AWgTiGAAELh2qyq8
OWte/2h8y9uUqjJ/H2wN
=7gpZ
-----END PGP SIGNATURE-----

--uEV2qNAmkWoUMAPn3qV0UukWc6QEnsX9n--
