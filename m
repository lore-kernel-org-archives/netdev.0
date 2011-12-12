From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] pch_can: fix error passive level test
Date: Mon, 12 Dec 2011 10:39:09 +0100
Message-ID: <4EE5CBBD.4050206@pengutronix.de>
References: <1323674180-16916-1-git-send-email-xi.wang@gmail.com> <4EE5B5D9.3030702@grandegger.com> <4EE5C6A7.1070506@pengutronix.de> <4EE5C9F2.7050502@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig504F1BA76259E1D8B930D673"
Cc: Xi Wang <xi.wang@gmail.com>,
	Masayuki Ohtake <masa-korg@dsn.okisemi.com>,
	Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4EE5C9F2.7050502@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig504F1BA76259E1D8B930D673
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/12/2011 10:31 AM, Wolfgang Grandegger wrote:
> On 12/12/2011 10:17 AM, Marc Kleine-Budde wrote:
>> On 12/12/2011 09:05 AM, Wolfgang Grandegger wrote:
>>> On 12/12/2011 08:16 AM, Xi Wang wrote:
>>>> The test (((errc & PCH_REC) >> 8) > 127) would always be false becau=
se
>>>> the receive error counter ((errc & PCH_REC) >> 8) is at most 127, wh=
ere
>>>> PCH_REC is defined as 0x7f00.  To test whether the receive error cou=
nter
>>>> has reached the error passive level, the RP bit (15) should be used.=

>>>>
>>>> Signed-off-by: Xi Wang <xi.wang@gmail.com>
>>>
>>> Acked-by: Wolfgang Grandegger <wg@grandegger.com>
>>
>> Is this patch a candidate for stable?
>=20
> You mean for the "net" branch? Yes, I think so.

Even for all trees which contain this driver (in a working version),
which is v2.6.38 and newer.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig504F1BA76259E1D8B930D673
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk7ly78ACgkQjTAFq1RaXHMz7ACaA/hax1zzxlUuoqgwaKsEec1f
AgEAnins0chcvMWLjA/QOrqfXJMLj6WB
=t8mV
-----END PGP SIGNATURE-----

--------------enig504F1BA76259E1D8B930D673--
