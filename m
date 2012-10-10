From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2] flexcan: disable bus error interrupts for the i.MX28
Date: Wed, 10 Oct 2012 21:59:04 +0200
Message-ID: <5075D388.4000005@pengutronix.de>
References: <5075C832.8080102@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE93FF5E441781F97C37D16D9"
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Shawn Guo <shawn.guo@linaro.org>,
	Hui Wang <jason77.wang@gmail.com>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5075C832.8080102@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE93FF5E441781F97C37D16D9
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 10/10/2012 09:10 PM, Wolfgang Grandegger wrote:
> Due to a bug in most Flexcan cores, the bus error interrupt needs
> to be enabled. Otherwise we don't get any error warning or passive
> interrupts. This is _not_ necessary for the i.MX28 and this patch
                                                   ^^^ and i.MX6q

No need to resend the patch, I'll change this while applying the patch.

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

=46rom my point of view, this should go into linux-can.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigE93FF5E441781F97C37D16D9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iEYEARECAAYFAlB104gACgkQjTAFq1RaXHOtwgCfUtD2z80sfVYv8dBMAGt6B4Vp
0voAn1SI/nm2c0vtmrnxskkkKBv9XQxr
=N5eL
-----END PGP SIGNATURE-----

--------------enigE93FF5E441781F97C37D16D9--
