From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: rcar_can: Do not print virtual addresses
Date: Tue, 4 Apr 2017 18:00:29 +0200
Message-ID: <f7fd0378-1ae7-d3f0-6ccb-ea506815c9e8@pengutronix.de>
References: <1491214286-14370-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="BGrSe6rsiEw8spEUIxAkdoxNeO2IIs847"
Cc: linux-renesas-soc@vger.kernel.org, linux-can@vger.kernel.org,
        netdev@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>,
        Wolfgang Grandegger <wg@grandegger.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1491214286-14370-1-git-send-email-geert+renesas@glider.be>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--BGrSe6rsiEw8spEUIxAkdoxNeO2IIs847
Content-Type: multipart/mixed; boundary="0gLcRcEWAh6o9jLb0wBAkiCLBgwKKDgHk";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Geert Uytterhoeven <geert+renesas@glider.be>,
 Wolfgang Grandegger <wg@grandegger.com>,
 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: linux-renesas-soc@vger.kernel.org, linux-can@vger.kernel.org,
 netdev@vger.kernel.org
Message-ID: <f7fd0378-1ae7-d3f0-6ccb-ea506815c9e8@pengutronix.de>
Subject: Re: [PATCH] can: rcar_can: Do not print virtual addresses
References: <1491214286-14370-1-git-send-email-geert+renesas@glider.be>
In-Reply-To: <1491214286-14370-1-git-send-email-geert+renesas@glider.be>

--0gLcRcEWAh6o9jLb0wBAkiCLBgwKKDgHk
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 04/03/2017 12:11 PM, Geert Uytterhoeven wrote:
> During probe, the rcar_can driver prints:
>=20
>     rcar_can e6e80000.can: device registered (regs @ e08bc000, IRQ76)
>=20
> The "regs" value is a virtual address, exposing internal information,
> hence stop printing it.  The (useful) physical address is already
> printed as part of the device name.
>=20
> Fixes: fd1159318e55e901 ("can: add Renesas R-Car CAN driver")
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Thanks, applied and included in pull request.

Mar

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--0gLcRcEWAh6o9jLb0wBAkiCLBgwKKDgHk--

--BGrSe6rsiEw8spEUIxAkdoxNeO2IIs847
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAljjwx0ACgkQHv7KIOw4
HPZhfgf/X1J5WvE27xyYb9VKkg/fC6ZFuFzD2xWtWk7m/PcEkTYpvaqQKzBNYrBD
LdicbRvX2ttPMMTDNxq9CiiDUBv5xJi1KL9TUnCXQCf1VKsywbbZoulA/clS42l2
xVlng9rxz1/16wljtQu2Yyp/n6vVxjwwc+wdGXxhfuhT1A6oRL1ocsE5qGK9N7Zq
nWQmOJ9j/MQ10oRQknvoh+zxAIZfR3zGql3Xe3I91OjBbhCH/02eDq1sYb5OmE29
VAf3K6My+96Fiq+tLEBj53Olms9q4QcqRDAXjY5Vx6TQ6c5t5Nk2LrGKmL1BxugD
+9M2STXRopX7uafnChxqJLENkdqBnw==
=KzDu
-----END PGP SIGNATURE-----

--BGrSe6rsiEw8spEUIxAkdoxNeO2IIs847--
