From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: c_can: Handle lost message before EOB
Date: Mon, 28 Oct 2013 10:08:03 +0100
Message-ID: <526E2973.6090905@pengutronix.de>
References: <1382950480-12515-1-git-send-email-mpa@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="4dnXTfDLU5AKrpl31p0R3g43N5dRwOnSQ"
Cc: Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: Markus Pargmann <mpa@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1382950480-12515-1-git-send-email-mpa@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--4dnXTfDLU5AKrpl31p0R3g43N5dRwOnSQ
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 10/28/2013 09:54 AM, Markus Pargmann wrote:
> If we handle end of block messages with higher priority than a lost
> message, we can run into an endless interrupt loop.
>=20
> This is reproducable with a am335x processor and "cansequence -r" at
> 1Mbit. As soon as we loose a packet we can't escape from a interrupt
> loop.
>=20
> This patch handles lost packets before EOB packets.
>=20
> Signed-off-by: Markus Pargmann <mpa@pengutronix.de>

Thanks, applied to can.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--4dnXTfDLU5AKrpl31p0R3g43N5dRwOnSQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlJuKXQACgkQjTAFq1RaXHM61wCeLbbGwIVvk5Z2oympmZZJQhAo
E24AmwbRsez7TxFD2bT/EVEBNDTRJYkH
=agCZ
-----END PGP SIGNATURE-----

--4dnXTfDLU5AKrpl31p0R3g43N5dRwOnSQ--
