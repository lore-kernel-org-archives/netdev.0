From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2] can: c_can: add xceiver enable/disable support
Date: Wed, 20 Jan 2016 15:29:02 +0100
Message-ID: <569F99AE.6080200@pengutronix.de>
References: <1453297443-23279-1-git-send-email-m.grzeschik@pengutronix.de>
 <20160120141151.GA626@airbook.eia.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="57gDUncpU6cftpOvEfbHnUjq45O88NDsm"
To: Michael Grzeschik <m.grzeschik@pengutronix.de>, wg@grandegger.com,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20160120141151.GA626@airbook.eia.lan>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--57gDUncpU6cftpOvEfbHnUjq45O88NDsm
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/20/2016 03:11 PM, Kurt Van Dijck wrote:
>=20
>> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_c=
an.c
>> index f91b094..0723aeb 100644
>> --- a/drivers/net/can/c_can/c_can.c
>> +++ b/drivers/net/can/c_can/c_can.c
>> @@ -1263,6 +1271,10 @@ int register_c_can_dev(struct net_device *dev)
>>  	 */
>>  	pinctrl_pm_select_sleep_state(dev->dev.parent);
>> =20
>> +	priv->reg_xceiver =3D devm_regulator_get(priv->device, "xceiver");
>=20
> I assume "xceiver" is the shorter name for "transceiver"?
> In that case, I suggest changing the devicetree label to "transceiver".=

> It would become a mess if different drivers use different names.
> I see no real benefit for naming it "xceiver". "trx" is even shorter :-=
)
> See also http://www.acronymfinder.com/TRX.html
>=20
> The internals, like variable names, do not really matter here.
>=20
> I haven't looked at other driver, yet the argument still stands.

The transceiver is named xceiver in all drivers.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--57gDUncpU6cftpOvEfbHnUjq45O88NDsm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWn5muAAoJEP5prqPJtc/HL7kH/3AAT+BvqSFxFKr9M+1DCkuH
mn6CQgzeqBEKppYZRML4hn/5HYFNd7vUxamg6doMCxuA1T+tB4AwxRu+nl+RqIKh
hQr8W0tHyVx2/RR0rz/rt7uZun9RnRUMmUgSVe40EoRQhCQnUPIshQVGMz9Zx2QJ
sDTHllwLtoimEhGUOjNQAoJvBmUS5nS/GFKklizLgtJIij/VJmnxxvAKIuQFhYeM
ek7PRlP9FeYHUdq+w03pYms73pXBkI9HruzkQCLyFqIRP6AzDo9fPVBcM7JK+/Dq
u15uE6YsO0tc9yyiKh3j7GW6bonyzu4SmxzmGiIds3i/S295Ft3ugqv8IEK3gm0=
=zPRj
-----END PGP SIGNATURE-----

--57gDUncpU6cftpOvEfbHnUjq45O88NDsm--
