From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH v2 3/3] net/fec: add imx6q enet support
Date: Wed, 21 Sep 2011 14:26:33 +0200
Message-ID: <20110921122633.GH1966@pengutronix.de>
References: <1316603432-20032-1-git-send-email-shawn.guo@linaro.org>
 <1316603432-20032-4-git-send-email-shawn.guo@linaro.org>
 <20110921113239.GF1966@pengutronix.de>
 <20110921115821.GF28907@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Dx9iWuMxHO1cCoFc"
Cc: Shawn Guo <shawn.guo@linaro.org>,
	"David S. Miller" <davem@davemloft.net>, patches@linaro.org,
	netdev@vger.kernel.org,
	Troy Kisky <troy.kisky@boundarydevices.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	linux-arm-kernel@lists.infradead.org,
	Lothar =?iso-8859-15?Q?Wa=DFmann?= <LW@KARO-electronics.de>
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57487 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115Ab1IUM0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 08:26:36 -0400
Content-Disposition: inline
In-Reply-To: <20110921115821.GF28907@S2100-06.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Dx9iWuMxHO1cCoFc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 21, 2011 at 07:58:22PM +0800, Shawn Guo wrote:
> On Wed, Sep 21, 2011 at 01:32:39PM +0200, Wolfram Sang wrote:
> >=20
> > > +/* Controller has GBIT support */
> > > +#define FEC_QUIRK_HAS_GBIT		(1 << 3)
> >=20
> > Heh, this is not really a quirk, but a nice feature :) I think we can
> > drop QUIRK if we see driver_data more as "flags" instead of "quirks"?
> > Minor, though.
> >=20
> As you have told, all these FEC_QUIRK_* are just flags actually.  The
> name was pick to keep the consistency, as they are all used for the
> same purpose.

I think introducing FEC_FEATURE_HAS_GBIT would be consistent enough, but
as I said, I don't mind much.

> > Also minor, but the patch looks like a good oportunity to start
> > replacing magic values with proper defines?
> >=20
> There are already so many magic numbers.  It really deserves a separated
> patch.

That is the other possibility, yes. Which sadly never happened.

> I heard that Uwe had a plan to do that some time ago.  He gives up
> now? :)

I don't know about this case. Also, it is not about blaming here. It is
totally okay for you to say that you don't want to change your patch to
start replacing the magic values. I mainly wanted to point out the
oportunity here.

Regards,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--Dx9iWuMxHO1cCoFc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk551/kACgkQD27XaX1/VRuIkACbB3e3jI3txLpY6L4S9dtZl7Qr
ta4An1LkeICqC9qAlawHe2+BJ4a+eIVT
=lBMX
-----END PGP SIGNATURE-----

--Dx9iWuMxHO1cCoFc--
