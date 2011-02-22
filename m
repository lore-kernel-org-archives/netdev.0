From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] ax88796: depend on HAS_IOMEM not on individual ARCHs
Date: Tue, 22 Feb 2011 22:42:30 +0100
Message-ID: <4D642DC6.2010307@pengutronix.de>
References: <20110222.111856.102538007.davem@davemloft.net>	<1298405998-6214-1-git-send-email-mkl@pengutronix.de> <20110222.123732.70186533.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig044265E4D3BE49B0179D87E6"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56255 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754320Ab1BVVmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 16:42:35 -0500
In-Reply-To: <20110222.123732.70186533.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig044265E4D3BE49B0179D87E6
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 02/22/2011 09:37 PM, David Miller wrote:
> I know it's going to cause allmodconfig build errors on sparc64,
> for example.

How to fix?
> drivers/net/ax88796.c:195: error: implicit declaration of function 'rea=
dsw'
> drivers/net/ax88796.c:198: error: implicit declaration of function 'rea=
dsb'

Use "ioreadX_rep" or add a "!SPARC64" to Kconfig?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig044265E4D3BE49B0179D87E6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk1kLcoACgkQjTAFq1RaXHP6HwCfSaud4UydVnHsAbNYTnBImvAB
p8YAn2KRdI9eGML+z5y6vcvpC5ctHNvr
=Jovd
-----END PGP SIGNATURE-----

--------------enig044265E4D3BE49B0179D87E6--
