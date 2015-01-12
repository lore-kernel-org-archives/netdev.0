From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 2/4] can: kvaser_usb: Update error counters before
 exiting on OOM
Date: Mon, 12 Jan 2015 12:09:32 +0100
Message-ID: <54B3AB6C.8020900@pengutronix.de>
References: <20141223154654.GB6460@vivalin-002> <20150111200544.GA8855@linux> <20150111201116.GB8855@linux> <20150111201519.GC8855@linux>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Nkn8OlFqRbTlCVRgHfekOXijXlK99XM4C"
Cc: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150111201519.GC8855@linux>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Nkn8OlFqRbTlCVRgHfekOXijXlK99XM4C
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/11/2015 09:15 PM, Ahmed S. Darwish wrote:
> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>=20
> Let the error counters be more accurate in case of Out of
> Memory conditions.

Please have a look at kvaser_usb_rx_error(), the whole state handling is
omitted in case of OOM.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Nkn8OlFqRbTlCVRgHfekOXijXlK99XM4C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUs6tsAAoJECte4hHFiupUPkMP/24Tulw6tXRPXAY3dfT1XDZ2
H9SwhCYdho08W7t8H31/VMoKEBJvYZ61cQyGkRSziISII1Ln9v3wIksnb53gMX7F
XZXlxrWqKx/WHP9Am1lQ0ArSXC5z2bqyQDl7DtVKMAiYoAqajKnVmJgErNPeo/Zc
GlyKiAIrD+qLpOQZmPtcCIPuMrFldx1IXxzGnsas2Nr82CCXIPQqWJlwaayXh9SM
Sl3C6NdboucJVAe+g14ObTg24n5tKXErRaiWSIrWfZqNIhMujl4vU9qOETdU5mol
gGiQF1w8DBrUac3X+Oxd3+wwTii5MTP0XErS3MnAG6nmCI3Y/UJviabuhUAVgMP7
I9RVZcPQyyeRi/k6n4s91oa9VJiDiGNVUhXrcmog6sMY3AUFy9bTOi5A0qHQ7Olh
7j5D+FXwXEKUleinkJsOe0lhQGtCqeizqFmhXQk2rYYrw4dB0JeM8gB3PYh7J4D6
2/pOus/8w1+alOLujiakdI3TwgmCyDeg64YHVjuRUwTfckNVg7Gb4KB3AYTDrXRx
MEy09WCZV6tkQBqGTamd+cji46zIPoeBDpRwmO2bMO39wFP59hAh8q24MvgxApPa
G7JQNGHVkmt2Z+VJJHM12sa8WxSIYrzJEDeKkNPIA6O5WMp4rv0Kawfmt4h60nU6
aX1ELCrihyPqu8Syj5Xy
=JvbW
-----END PGP SIGNATURE-----

--Nkn8OlFqRbTlCVRgHfekOXijXlK99XM4C--
