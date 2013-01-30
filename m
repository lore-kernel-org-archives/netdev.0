From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [RFC 3/3] arm: mach-mxs: make enabling enet_out a legacy function
Date: Wed, 30 Jan 2013 08:58:32 +0100
Message-ID: <20130130075832.GA13075@pengutronix.de>
References: <1359470773-14290-1-git-send-email-w.sang@pengutronix.de>
 <1359470773-14290-4-git-send-email-w.sang@pengutronix.de>
 <20130130054833.GA24450@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4Ckj6UjgE2iN1+kY"
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Shawn Guo <shawn.guo@freescale.com>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59700 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769Ab3A3H6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 02:58:35 -0500
Content-Disposition: inline
In-Reply-To: <20130130054833.GA24450@S2100-06.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 30, 2013 at 01:48:40PM +0800, Shawn Guo wrote:
> On Tue, Jan 29, 2013 at 03:46:13PM +0100, Wolfram Sang wrote:
> > @@ -351,7 +359,7 @@ static void __init tx28_post_init(void)
> >  	struct pinctrl *pctl;
> >  	int ret;
> > =20
> > -	enable_clk_enet_out();
> > +	legacy_enable_clk_enet_out();
>=20
> I think TX28 is the only case that really needs to turn on enet_out
> clock at platform level, since it has some dirty work about PHY to do
> here.  With with fec driver handling the clock, enable_clk_enet_out()
> can just be removed for other boards.

I would love to, but this will cause regression on boards which update
the kernel but not the devicetree (no third clock), or?

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--4Ckj6UjgE2iN1+kY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlEI0qgACgkQD27XaX1/VRtO0wCfUTjKSxyCZI8ktUUPrS3lqqbd
zzgAoLmCfcabgVVAjoJWjycxlnimw0jL
=AAVy
-----END PGP SIGNATURE-----

--4Ckj6UjgE2iN1+kY--
