From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH net] mscan: zero accidentally copied register content
Date: Thu, 06 Oct 2011 20:25:24 +0200
Message-ID: <4E8DF294.7060707@pengutronix.de>
References: <4E8C78E8.3010605@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigEE8750CC6416954630333F34"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch@gmail.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:43626 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754178Ab1JFSZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 14:25:30 -0400
In-Reply-To: <4E8C78E8.3010605@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigEE8750CC6416954630333F34
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 10/05/2011 05:34 PM, Oliver Hartkopp wrote:
> Due to the 16 bit access to mscan registers there's too much data copie=
d to
> the zero initialized CAN frame when having an odd number of bytes to co=
py.
> This patch clears the data byte read from the invalid register entry.
>=20
> Reported-by: Andre Naujoks <nautsch@gmail.com>
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

This problem have some other drivers, too, e.g. the at91 and the flexcan
driver both copy unconditionally all 8 bytes from the hardware. However,
I don't know if the hardware sets the remaining bytes to zero.

cheers, Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigEE8750CC6416954630333F34
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk6N8pcACgkQjTAFq1RaXHPpwwCfVW2eu0Ot38LnEvOWqy1QGJ1B
mS0An27ZYicC4RmTdoU586IBj13Y3JEf
=X4Wk
-----END PGP SIGNATURE-----

--------------enigEE8750CC6416954630333F34--
