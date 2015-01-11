From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 4/4] can: kvaser_usb: Retry first bulk transfer on
 -ETIMEDOUT
Date: Sun, 11 Jan 2015 21:51:10 +0100
Message-ID: <54B2E23E.1090108@pengutronix.de>
References: <20141223154654.GB6460@vivalin-002> <20150111200544.GA8855@linux> <20150111201116.GB8855@linux> <20150111201519.GC8855@linux> <20150111203612.GA8999@linux> <20150111204508.GB8999@linux>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="6ujMwJMccFsjISkuuGfnV4WpGXtCSjAFa"
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Linux-USB <linux-usb@vger.kernel.org>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20150111204508.GB8999@linux>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--6ujMwJMccFsjISkuuGfnV4WpGXtCSjAFa
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/11/2015 09:45 PM, Ahmed S. Darwish wrote:
> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>=20
> (This is a draft patch, I'm not sure if this fixes the USB
> bug or only its psymptom. Feedback from the linux-usb folks
> is really appreciated.)
>=20
> When plugging the Kvaser USB/CAN dongle the first time, everything
> works as expected and all of the transfers from and to the USB
> device succeeds.
>=20
> Meanwhile, after unplugging the device and plugging it again, the
> first bulk transfer _always_ returns an -ETIMEDOUT. The following
> behaviour was observied:
>=20
> - Setting higher timeout values for the first bulk transfer never
>   solved the issue.
>=20
> - Unloading, then loading, our kvaser_usb module in question
>   __always__ solved the issue.
>=20
> - Checking first bulk transfer status, and retry the transfer
>   again in case of an -ETIMEDOUT also __always__ solved the issue.
>   This is what the patch below does.
>=20
> - In the testing done so far, this issue appears only on laptops
>   but never on PCs (possibly power related?)
>=20
> Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>

Does this patch apply apply between 3 and 4? If not, please re-arrange
the series. As this is a bug fix, patches 1, 2 and 4 will go via
net/master, 3 will go via net-next/master.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--6ujMwJMccFsjISkuuGfnV4WpGXtCSjAFa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUsuI+AAoJECte4hHFiupUe2kP/0urhQtVHePk4wY2VMnTiej5
osqNACCZqB1kGjj1NeMBrnDaTN5Gz9+7KFQPRVrCqMK3pfS4/DB33yK82Z+aSnSi
QKXbXx/qj1BgHxWVlzQCqIW2w8bTU9v7pJenWIo/JKSEqwNMXhiisd6lqfwUl2xt
Kh3iXHVgmoX3/iZAjT+hev3qYKzvlWfr07qVkReP+7YBz70LDE+EHKJsXpRrfGTb
Q+GEqvHJ9oLg/EgaY5KcrpQazpTG3qyOg+0BufWGRbXoAKa3y4rgEsZuCdEStriV
fJSu26nEfju0ctODB4VSnVfySBiSN+SK34M1cfoQQp9o0NZHz9Eo6an+O7O8tvON
F84oUw8VuwXoV8BoSLGH1bt0yCBZMaTH/J7n3HPbJoeQ7BmZA+3m176I3IRjJtOX
QJSuyCtsXBwZAesVNpygiIMrUol9+C2mV8n7I+Xwvg/wzxnsz6t9oh7L+WcflNaV
PnUEdpI4PELk4U/xxE5YYdZmI63PY7r8APCb6O9V4vhu6wIkAJFKZlvFLRFH8XbG
BTc9FKw60zviTbgdXA/5Tb2avyUHF4sbobNnpK+cMUEaRcX754G6xY2uG/G8z6YO
1jXkXUOEFafPlSLZ0f6qNFGyaHWGobdqTAoW2ZQoOHhqbSLcYXJb5WIsordOKu9b
J6p8iR/eqCUNKFH6IenJ
=lRBY
-----END PGP SIGNATURE-----

--6ujMwJMccFsjISkuuGfnV4WpGXtCSjAFa--
