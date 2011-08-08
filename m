From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Mon, 08 Aug 2011 15:05:05 +0200
Message-ID: <4E3FDF01.1060708@pengutronix.de>
References: <1312641270-6018-1-git-send-email-holt@sgi.com> <1312641270-6018-6-git-send-email-holt@sgi.com> <4E3FA066.3020301@grandegger.com> <20110808113136.GS4926@sgi.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig3D34A02B5638D4C313BEDBB9"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	U Bhaskar-B22300 <B22300@freescale.com>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: Robin Holt <holt@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52667 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140Ab1HHNFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 09:05:11 -0400
In-Reply-To: <20110808113136.GS4926@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig3D34A02B5638D4C313BEDBB9
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 08/08/2011 01:31 PM, Robin Holt wrote:
> OK.  Dug a bit more.  The p1010 built-in clocksource seems to be the
> periphereal clock frequency which is system bus frequency divided
> by 2.  The clock source can not be changed, but the clock divider can

On arm the clock source is selected by bit 13 of CTRL:

> This bit selects the clock source to the CAN protocol interface (CPI)
> to be either the peripheral clock (driven by the PLL) or the crystal
> oscillator clock. The selected clock is the one fed to the prescaler
> to generate the SCLK (SCLK). In order to guarantee reliable
> operation, this bit must only be changed while the module is in
> disable mode. See Section 24.4.8.4, =93Protocol Timing,=94 for more
> information.

> 0 The CAN engine clock source is the oscillator clock (24.576 MHz)
> 1 The CAN engine clock source is the bus clock (66.5 MHz)

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig3D34A02B5638D4C313BEDBB9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk4/3wEACgkQjTAFq1RaXHNgzQCghP2lBuoyhHJguWrByDiIZqch
CdYAnjAtL1Iy5WBZwWKUfBNXhm38OEhw
=BjIs
-----END PGP SIGNATURE-----

--------------enig3D34A02B5638D4C313BEDBB9--
