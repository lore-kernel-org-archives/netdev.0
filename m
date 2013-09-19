From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH net 1/3] slip/slcan: added locking in wakeup function
Date: Thu, 19 Sep 2013 11:36:09 +0200
Message-ID: <523AC589.5040006@pengutronix.de>
References: <1379093833-4949-1-git-send-email-nautsch2@gmail.com> <1379093833-4949-2-git-send-email-nautsch2@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="VACTNhKFEl9krSAacK6o99Mq1EP5LRWUW"
Cc: davem@davemloft.net, Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andre Naujoks <nautsch2@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1379093833-4949-2-git-send-email-nautsch2@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--VACTNhKFEl9krSAacK6o99Mq1EP5LRWUW
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/13/2013 07:37 PM, Andre Naujoks wrote:
> The locking is needed, since the the internal buffer for the CAN frames=
 is
> changed during the wakeup call. This could cause buffer inconsistencies=

> under high loads, especially for the outgoing short CAN packet skbuffs.=

>=20
> The needed locks led to deadlocks before commit
> "5ede52538ee2b2202d9dff5b06c33bfde421e6e4 tty: Remove extra wakeup from=
 pty
> write() path", which removed the direct callback to the wakeup function=
 from the
> tty layer.

What does that mean for older kernels?
(< 5ede52538ee2b2202d9dff5b06c33bfde421e6e4)

> As slcan.c is based on slip.c the issue in the original code is fixed, =
too.
>=20
> Signed-off-by: Andre Naujoks <nautsch2@gmail.com>
Acked-by: Marc Kleine-Budde  <mkl@pengutronix.de>

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--VACTNhKFEl9krSAacK6o99Mq1EP5LRWUW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlI6xYkACgkQjTAFq1RaXHP3WQCfb9iLAgL99AkUY46wJgSpmFrL
cywAnAgai9lg5kttki3STC3xU5aweDXR
=4evM
-----END PGP SIGNATURE-----

--VACTNhKFEl9krSAacK6o99Mq1EP5LRWUW--
