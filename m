From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH RESEND] can: mcp251x: Replace power callbacks with regulator
 API
Date: Sun, 18 Aug 2013 10:00:34 +0200
Message-ID: <52107F22.80002@pengutronix.de>
References: <1375963227-6468-1-git-send-email-shc_work@mail.ru> <20130817083014.a01144051b158c34ec7dd9d9@mail.ru> <520FD60E.4040709@pengutronix.de> <1376773805.878998573@f169.i.mail.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="uvu50eHw3xR5l8WRVkQwRidfuI41wte0L"
Cc: Russell King <linux@arm.linux.org.uk>, netdev@vger.kernel.org,
	Haojian Zhuang <haojian.zhuang@gmail.com>,
	linux-can@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Eric Miao <eric.y.miao@gmail.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: Alexander Shiyan <shc_work@mail.ru>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1376773805.878998573@f169.i.mail.ru>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--uvu50eHw3xR5l8WRVkQwRidfuI41wte0L
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 08/17/2013 11:10 PM, Alexander Shiyan wrote:
[...]

>>> - xceiver-supply: Regulator that powers the CAN transceiver
>>
>> which translates into:
>>
>>> priv->reg_xceiver =3D devm_regulator_get(&pdev->dev, "xceiver");
>>
>> Can you please use "xceiver" instead of "transceiver", so that future =
DT
>> binding will fit the scheme.
>=20
> OK. I am not ready to add DT support yet, but it can be added later,

DT support can be added later, I just want to make sure that you use
"xceiver" for the regulator, so that you don't need to change any code
if DT is added.

> so v2 will contain 3 parts:

If you mean series v3 consists of three patches....

> 1 - Replace power callbacks with regulator API
> 2 - Eliminate mcp251x_platform_data->irq_flags
> 3 - Replace oscillator_frequency with CLK API (and remove mcp251x.h hea=
der)
>=20
> Are you OK with such changes?

=2E..them I'm okay :)

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--uvu50eHw3xR5l8WRVkQwRidfuI41wte0L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlIQfyIACgkQjTAFq1RaXHMpEgCffD4vMzXBf3axUw7j7z0egHnI
zQcAn17jb+IoenVagyc+IXphEbQ3ixZq
=09BH
-----END PGP SIGNATURE-----

--uvu50eHw3xR5l8WRVkQwRidfuI41wte0L--
