From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] pch_can: fix error passive level test
Date: Mon, 12 Dec 2011 10:17:27 +0100
Message-ID: <4EE5C6A7.1070506@pengutronix.de>
References: <1323674180-16916-1-git-send-email-xi.wang@gmail.com> <4EE5B5D9.3030702@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig4ABE6ACD97868749FD56CDBB"
Cc: Xi Wang <xi.wang@gmail.com>,
	Masayuki Ohtake <masa-korg@dsn.okisemi.com>,
	Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4EE5B5D9.3030702@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig4ABE6ACD97868749FD56CDBB
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/12/2011 09:05 AM, Wolfgang Grandegger wrote:
> On 12/12/2011 08:16 AM, Xi Wang wrote:
>> The test (((errc & PCH_REC) >> 8) > 127) would always be false because=

>> the receive error counter ((errc & PCH_REC) >> 8) is at most 127, wher=
e
>> PCH_REC is defined as 0x7f00.  To test whether the receive error count=
er
>> has reached the error passive level, the RP bit (15) should be used.
>>
>> Signed-off-by: Xi Wang <xi.wang@gmail.com>
>=20
> Acked-by: Wolfgang Grandegger <wg@grandegger.com>

Is this patch a candidate for stable?

> The C_CAN driver, which supports the same CAN controller, does handle
> the error passive state correctly. This reminds me to get rid of pch_ca=
n
> in favor of C_CAN sooner than later.

+1

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig4ABE6ACD97868749FD56CDBB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk7lxqcACgkQjTAFq1RaXHMVWACfSsOlMmEfIcZUB1/ljKP7sFyc
3jIAoIr6uttnT654ACfV7T8WXGo7HaWw
=/nPs
-----END PGP SIGNATURE-----

--------------enig4ABE6ACD97868749FD56CDBB--
