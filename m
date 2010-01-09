From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [RFC] PCMCIA patches for 2.6.34
Date: Sat, 9 Jan 2010 13:16:34 +0100
Message-ID: <20100109121634.GB25729@pengutronix.de>
References: <20100106114531.GA29913@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jho1yZJdad60DJr+"
To: linux-pcmcia@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:54980 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752849Ab0AIMQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2010 07:16:35 -0500
Content-Disposition: inline
In-Reply-To: <20100106114531.GA29913@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--jho1yZJdad60DJr+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 06, 2010 at 12:45:31PM +0100, Dominik Brodowski wrote:
> Hey,
>=20
> here are some patches relating to the PCMCIA subsystem, and intended for
> 2.6.34. I'm interested in your input to this patch series. They'll be
> sent to the PCMCIA list shortly, with CC to other lists if deemed
> appropriate.
>=20
>       pcmcia: make use of pcmcia_dev_resume() return value
>       pcmcia: remove remaining unused IRQ_FIRST_SHARED parameter
>       pcmcia: do not meddle with already assigned resources
>       pcmcia: validate CIS, not CIS cache.
>       pcmcia: cleanup pccard_validate_cis()
>       pcmcia: improve check for same card in slot after resume
>       pcmcia: CardBus doesn't need CIS access
>       pcmcia: call CIS cleanup from ds.c
>       pcmcia: rsrc_nonstatic io memory probe improvements
>       pcmcia: do not lock socket driver module in pcmcia_get_socket()
>       pcmcia: do not lock socket driver module on card insert
>       pcmcia: remove useless indirection
>       pcmcia: remove some rsrc_mgr indirections
>       pcmcia: m32r uses static socket resources
>       pcmcia: m8xx_pcmcia.c should use iodyn resource manager

Whole series:

Tested-by: Wolfram Sang <w.sang@pengutronix.de>

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--jho1yZJdad60DJr+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAktIc6IACgkQD27XaX1/VRu2SgCguTstA5jkn7F97hxNSTmuoZGj
CQ8AnjbcQqu6tApv20W+lpVEI3pPeOi1
=Irvg
-----END PGP SIGNATURE-----

--jho1yZJdad60DJr+--
