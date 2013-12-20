From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: ti_hecc: Use the OMAP2PLUS dependency for omap2plus
 devices
Date: Fri, 20 Dec 2013 20:56:01 +0100
Message-ID: <52B4A0D1.9010503@pengutronix.de>
References: <1387542110-26596-1-git-send-email-ezequiel.garcia@free-electrons.com> <52B439AE.7020304@pengutronix.de> <20131220125236.GA26648@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="uXpUOM0sWIstRUpfiL9bqjdmUWLuWl3fw"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55562 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624Ab3LTT4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 14:56:08 -0500
In-Reply-To: <20131220125236.GA26648@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--uXpUOM0sWIstRUpfiL9bqjdmUWLuWl3fw
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 12/20/2013 01:52 PM, Ezequiel Garcia wrote:
> On Fri, Dec 20, 2013 at 01:35:58PM +0100, Marc Kleine-Budde wrote:
>> On 12/20/2013 01:21 PM, Ezequiel Garcia wrote:
>>> OMAP's ti_hecc driver is used to support the CAN controller on many
>>> omap2plus SoCs (OMAP2430, OMAP3, OMAP4, OMAP5 and AM335x).
>>> Constrain the driver to OMAP2PLUS, which is the super-set of all the
>>> other SoCs variants.
>>
>> Why not enable it for all ARM platforms to get a bigger compile covera=
ge?
>>
>=20
> Hm.. Isn't the COMPILE_TEST option for getting compile coverage?
>=20
> If the IP is only available on OMAP SoCs, it makes sense to only allow
> building it there, but I don't really have a strong opinion.

We've replaced the depends on ARCH_* in the flexcan and at91 driver by a
depends on ARM.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--uXpUOM0sWIstRUpfiL9bqjdmUWLuWl3fw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlK0oNIACgkQjTAFq1RaXHOxyACdEZYVscdBWQVbgSjw66A8ebx0
5FcAn3sJ74tOIMNptJt529HGXhxFP9Zl
=7TZE
-----END PGP SIGNATURE-----

--uXpUOM0sWIstRUpfiL9bqjdmUWLuWl3fw--
