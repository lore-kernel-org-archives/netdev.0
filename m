From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: macb:
Date: Wed, 16 Feb 2011 23:31:26 +0100
Message-ID: <4D5C503E.8010203@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigDA99B3B90C01A7ACCAB10AF1"
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
To: Netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:43754 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753186Ab1BPWbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 17:31:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigDA99B3B90C01A7ACCAB10AF1
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello,

I added type checking[1] to platform_set_drvdata and got the following
warning:

drivers/net/macb.c: In function 'macb_mii_init':
drivers/net/macb.c:263: warning: passing argument 1 of 'platform_set_drvd=
ata' from incompatible pointer type

I'm new to the mii_bus stuff and don't see how to fix it.

regards, Marc

[1] https://lkml.org/lkml/2011/2/16/380
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigDA99B3B90C01A7ACCAB10AF1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk1cUEEACgkQjTAFq1RaXHNcjACfZ24CkBSEWluxgU2KwXcwpzPr
M5gAnA2buq2911k7lyGAKFnJE1ZK5eCf
=4iw/
-----END PGP SIGNATURE-----

--------------enigDA99B3B90C01A7ACCAB10AF1--
