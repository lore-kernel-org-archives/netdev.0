From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] drivers: net: Remove remaining alloc/OOM messages
Date: Fri, 08 Feb 2013 00:29:14 +0100
Message-ID: <511438CA.8060003@pengutronix.de>
References: <1360273587.27863.15.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2UHVEOGTHORNDWVVOWLUJ"
Cc: netdev <netdev@vger.kernel.org>, linux-can@vger.kernel.org,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, wil6210@qca.qualcomm.com,
	brcm80211-dev-list@broadcom.com,
	devicetree-discuss <devicetree-discuss@lists.ozlabs.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1360273587.27863.15.camel@joe-AO722>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2UHVEOGTHORNDWVVOWLUJ
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 02/07/2013 10:46 PM, Joe Perches wrote:
> alloc failures already get standardized OOM
> messages and a dump_stack.
>=20
> For the affected mallocs around these OOM messages:
>=20
> Converted kmallocs with multiplies to kmalloc_array.
> Converted a kmalloc/memcpy to kmemdup.
> Removed now unused stack variables.
> Removed unnecessary parentheses.
> Neatened alignment.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> Let me know if you want multiple small patches instead.
>=20
>  drivers/net/can/usb/ems_usb.c                      |  4 +-

For ems_usb.c

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

regards,
Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2UHVEOGTHORNDWVVOWLUJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlEUON8ACgkQjTAFq1RaXHNawgCghkTouziZz1s9EyqAQmRtnyTg
t5QAoIsLAx7+P28BtRi4ralrnaIxHHZm
=jak+
-----END PGP SIGNATURE-----

------enig2UHVEOGTHORNDWVVOWLUJ--
