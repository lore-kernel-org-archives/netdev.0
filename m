From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] flexcan: Fix CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK
Date: Mon, 31 Oct 2011 23:49:41 +0100
Message-ID: <4EAF2605.9090005@pengutronix.de>
References: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA1DD@exch01-aklnz.MARINE.NET .INT> <4EAF21A6.702@pengutronix.de> <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA211@exch01-aklnz.MARINE.NET.INT>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig634FF29769D5BE5F73619BE1"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: Reuben Dowle <Reuben.Dowle@navico.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA211@exch01-aklnz.MARINE.NET.INT>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig634FF29769D5BE5F73619BE1
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 10/31/2011 11:43 PM, Reuben Dowle wrote:
> Currently the flexcan driver uses hardware local echo. This blindly
> echoes all transmitted frames to all receiving sockets, regardless what=

> CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK are set to.
>=20
> This patch now submits transmitted frames to be echoed in the transmit
> complete interrupt, preserving the reference to the sending socket.
> This allows the can protocol to correctly handle the local echo.
>=20
> Signed-off-by: Reuben Dowle <reuben.dowle@navico.com>

there were some comments inline in my original mail.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig634FF29769D5BE5F73619BE1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk6vJgoACgkQjTAFq1RaXHNUkACdF14ux33YGhFhmHgX67uSvXvQ
wi0An2zj3bvjkPQFDPRwk1Gc88hPciKa
=OCF1
-----END PGP SIGNATURE-----

--------------enig634FF29769D5BE5F73619BE1--
