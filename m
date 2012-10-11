From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2] flexcan: disable bus error interrupts for the i.MX28
Date: Thu, 11 Oct 2012 10:00:33 +0200
Message-ID: <50767CA1.3030600@pengutronix.de>
References: <5075C832.8080102@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig131138F29C2CA83960E72544"
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Shawn Guo <shawn.guo@linaro.org>,
	Hui Wang <jason77.wang@gmail.com>,
	David Miller <davem@davemloft.net>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5075C832.8080102@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig131138F29C2CA83960E72544
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 10/10/2012 09:10 PM, Wolfgang Grandegger wrote:
> Due to a bug in most Flexcan cores, the bus error interrupt needs
> to be enabled. Otherwise we don't get any error warning or passive
> interrupts. This is _not_ necessary for the i.MX28 and this patch
> disables bus error interrupts if "berr-reporting" is not requested.
> This avoids bus error flooding, which might harm, especially on
> low-end systems.
>=20
> To handle such quirks of the Flexcan cores, a hardware feature flag
> has been introduced, also replacing the "hw_ver" variable. We got
> some version info about what Flexcan core version is available on
> what Freescale SOC which have been summarized as comment.
>=20
> Changes since v1:
>=20
> - add known version info and hw bugs as comment
> - remove FLEXCAN_HAS_BROKEN_ERR_STATE for i.MX6Q

David was quick in applying the v1 version of this patch into his tree
directly. Wolfgang can you send an incremental patch? Please change the
list of can cores, according to Dong Aisheng, the mx6 has a glitch
filter, too.

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig131138F29C2CA83960E72544
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iEYEARECAAYFAlB2fKEACgkQjTAFq1RaXHPj3wCfXlMyBQ0YKqDED149Q2GHH0eI
Bt8AnjUtN1xxiubLgEGNxrqSjQEfO7ml
=4+Sx
-----END PGP SIGNATURE-----

--------------enig131138F29C2CA83960E72544--
