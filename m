From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 2/2] can: ti hecc module : add platform specific	initialization
 callback.
Date: Mon, 22 Feb 2010 17:00:41 +0100
Message-ID: <4B82AA29.4090200@pengutronix.de>
References: <1266845762-7809-1-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig9E2E3C8E747D9BF19593DF47"
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: Sriramakrishnan <srk@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59031 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754127Ab0BVQAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 11:00:53 -0500
In-Reply-To: <1266845762-7809-1-git-send-email-srk@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9E2E3C8E747D9BF19593DF47
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Sriramakrishnan wrote:
> CAN module on AM3517 requires programming of IO expander as part
> of init sequence - to enable CAN PHY. Added platform specific
> init callback to handle this.

Consider giving it a more descriptive name like "phy_switch" and adding
an argument to the function to enable/disable the phy. Put the routine
in the driver's open and close function.

Pleae also update the ti_hecc_platform_data documentation in the top of
ti_hecc.c

Have a look at the at91 for example.

cheers, Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig9E2E3C8E747D9BF19593DF47
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkuCqi4ACgkQjTAFq1RaXHOlTwCeI4hRV7PvXPH3zhr93Ip4EpOB
n8sAoIjqo3ETLqvH7VAljECRZnj06OEo
=PYdm
-----END PGP SIGNATURE-----

--------------enig9E2E3C8E747D9BF19593DF47--
