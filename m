From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5 1/3] can: sja1000: of: add per-compatible init hook
Date: Wed, 20 Jan 2016 16:34:28 +0100
Message-ID: <569FA904.4010705@pengutronix.de>
References: <1453285431-32498-1-git-send-email-mkl@pengutronix.de>
 <1453285431-32498-2-git-send-email-mkl@pengutronix.de>
 <20160120153041.GA6117@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="vJkJIDaK19TSbqnKUruFlJeAeXU5BV1wo"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Damien Riegel <damien.riegel@savoirfairelinux.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20160120153041.GA6117@localhost>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--vJkJIDaK19TSbqnKUruFlJeAeXU5BV1wo
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/20/2016 04:30 PM, Damien Riegel wrote:
>> +static const struct of_device_id sp_of_table[] =3D {
>> +	{ /* sentinel */ },
>> +};
>> +MODULE_DEVICE_TABLE(of, sp_of_table);
>> +
>=20
> I will give a try to this serie but it seems that
>=20
> 	{.compatible =3D "nxp,sja1000"},
>=20
> has disappeared of sp_of_table in v5.

Doh! This is of course broken. Wait for v6, please.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--vJkJIDaK19TSbqnKUruFlJeAeXU5BV1wo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWn6kEAAoJEP5prqPJtc/HDOUH/0bTtEm85j7v0BtxydMEOjiA
B8HX7pY9d1EEbN6l0lqp7Nubig32aqiyyBXRfFXa8K/ueIRCZjFSl1Hkw+KHcM9s
2A++wWZZ4nloWcP4jTiH+64zkvznwWGthpSRX5Ef/cz44TJtQHtJ4ygp65LKTr1j
rhyg19+HKJjKPEsM03PJ6Tvl5QYL422j26x4VeMThdBC8JXARi2DuYhw9RBUzEmG
jqaVVBoy1U069M7hCoS5aUq+UY9IlaFdmFz56naSJRER4cAF+yAufq/0tzWeMEtN
IG8jPMEWMWgPxbbL9vm05uOgAFRy0NQokGsKo6k7+VHMaZxCf6TzsGiM7/wlOfE=
=J9Qu
-----END PGP SIGNATURE-----

--vJkJIDaK19TSbqnKUruFlJeAeXU5BV1wo--
