From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <uwe@kleine-koenig.org>
Subject: Re: [PATCH 2/2] net: dsa: mv88e6xxx: Add 88E6176 device tree support
Date: Mon, 28 Nov 2016 09:09:40 +0100
Message-ID: <20161128080939.ippqlytvojitefkp@perseus.defre.kleine-koenig.org>
References: <1480280279-9552-1-git-send-email-afaerber@suse.de>
 <1480280279-9552-2-git-send-email-afaerber@suse.de>
 <20161127212709.GD13318@lunn.ch>
 <9500470d-09c3-3ecb-994b-3d108bffc99e@suse.de>
 <20161127220846.GH13318@lunn.ch>
 <e5d45b55-a4c1-3b5e-0bdc-a5e340b072d0@suse.de>
 <20161127231009.GA17704@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="f5cgf4jnlrji24wl"
Cc: Andreas =?iso-8859-1?Q?F=E4rber?= <afaerber@suse.de>,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Michal Hrusecki <Michal.Hrusecky@nic.cz>,
        Tomas Hlavacek <tomas.hlavacek@nic.cz>,
        Bed??icha Ko??atu <bedrich.kosata@nic.cz>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        linux-kernel@vger.kernel.org, devicetree@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:60699 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754060AbcK1IJ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 03:09:58 -0500
Content-Disposition: inline
In-Reply-To: <20161127231009.GA17704@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--f5cgf4jnlrji24wl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello Andrew,

On Mon, Nov 28, 2016 at 12:10:09AM +0100, Andrew Lunn wrote:
> > Try to see it from my perspective: I see that some vf610 device I don't
> > have (found via `git grep marvell,mv88e6` or so) uses
> > "marvell,mv88e6085". I then assume it has that device on board. How
> > would I know it doesn't? Same for the other boards you mention.
> >=20
> > Unfortunately some of your replies are slightly cryptic. Had you simply
> > replied 'please just use "marvell,mv88e6085" instead', it would've been
> > much more clear what you want. (Same for extending the subject instead
> > of just pointing to some FAQ.)
>=20
> By reading the FAQ you have learnt more than me saying put the correct
> tree in the subject line. By asking you to explain why you need a
> compatible string, i'm trying to make you think, look at the code and
> understand it. In the future, you might think and understand the code
> before posting a patch, and then we all save time.

I agree to Andreas though, that it makes an school teacher impression.
Something like:

	Please fix the subject. Check the FAQ for the details, which btw
	is worth a read completely.

is IMHO better in this regard and once you found the problem there you
don't need to ask back if it's that what was meant.

> > So are you okay with patch 1/2 documenting the compatible? Then we could
> > drop 2/2 and use "marvell,mv88e6176", "marvell,mv88e6085" instead of
> > just the latter. Or would you rather drop both and keep the actual chip
> > a comment?
>=20
> A comment only please.

I still wonder (and didn't get an answer back when I asked about this)
why a comment is preferred here. For other devices I know it's usual and
requested by the maintainers to use:

	compatible =3D "exact name", "earlyer device to match driver";

=2E This is more robust, documents the situation more formally and makes
it better greppable. The price to pay is only a few bytes in the dtb
which IMO is ok.

Best regards
Uwe

--f5cgf4jnlrji24wl
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEfnIqFpAYrP8+dKQLwfwUeK3K7AkFAlg75kAACgkQwfwUeK3K
7Amp1Af8Djhoytsdm7xFsAHwRRAmvzasbH0hBOEkn1cRn8GWH6J58pFJs9qyAMZY
C+9apAJW+CaEp4dONvDBvx8oHegxwK7MQIkjhOmo0rnx7Kw54m7bcdFIGsNbdyI5
ZifbKVVIlKrC5grulckNRWsvOJJaxc44zFVI9yg+okQIZEPv1Xtu0HWvp3Xc8ORA
7W31OolUYPdtguiw9Xh59P+/85ob1akxb+cC7+19hhrMCFF6WbIjXdAs596lc1Rj
HcyEfmyLhpZFodQC5YDIWqe/Y0H+pC4FF6H7B2PWab/6FshzklssYda29D2oYdG2
obHoL1O4X3Ipr2dDw+QLVcobyQ2nyA==
=KSyR
-----END PGP SIGNATURE-----

--f5cgf4jnlrji24wl--
