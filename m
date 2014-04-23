From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH v2] net: cadence: Add architecture dependencies
Date: Wed, 23 Apr 2014 12:34:02 +0100
Message-ID: <20140423113402.GV12304@sirena.org.uk>
References: <20140414153849.7138699b@endymion.delvare>
 <20140422203209.GH12304@sirena.org.uk>
 <535768E1.8050609@monstr.eu>
 <20140423094010.17d2d763@endymion.delvare>
 <5357897B.6020105@monstr.eu>
 <20140423124838.37aa0759@endymion.delvare>
 <5357A0A1.1020600@monstr.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zqSjrgky05FRiUsC"
Cc: Jean Delvare <jdelvare@suse.de>, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Fengguang Wu <fengguang.wu@intel.com>
To: Michal Simek <monstr@monstr.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:42767 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbaDWLeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 07:34:18 -0400
Content-Disposition: inline
In-Reply-To: <5357A0A1.1020600@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--zqSjrgky05FRiUsC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Apr 23, 2014 at 01:14:41PM +0200, Michal Simek wrote:
> On 04/23/2014 12:48 PM, Jean Delvare wrote:

> > Originally I wanted to hide the Cadence drivers from X86 kernel
> > configuration. If there's still a way to achieve that, let's do it. If
> > not, we can leave the hardware dependency for ARM_AT91_ETHER and drop
> > the one for MACB (and subsequently NET_CADENCE.) That's still better
> > than nothing.

> Any reason to hide this driver for x86?

Distro maintainers like Jean are complaining about build times for their
kernels if they enable absolutely everything so if they're never likely
to see any hardware using something they want to skip it.

--zqSjrgky05FRiUsC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJTV6UnAAoJELSic+t+oim9et0P+wd1Za5TiW1xdeh1ZAej7wiR
yhuOnIqJ7I+gwkDdupeTJs4138i/47mwgW7k8vQHd2or2eFEtkyalKtoXanGISd/
KQAKO3yOohwzsWRxt0AQEcaZN6WO9DgSnwTVid+a34CyUoC+jahnyA4KyOKaPNJQ
+A5YZrXSrk3hDMsqSmAOQRrXIMYG3CVb1CT7qLMwPyiIqrhnbwYhqhXZQquLt/Om
ER9WEZ12k8tIsVCRK9xCa2pKBsAb6eiEc3ySIIFL8COYe256tmkZhfQyzjtulFgb
iOA8clIUyoU3GdmOezgIa8nYhvp0MSqWL0jVJZeAVacV+5xqbC4dJg0DbX8FOq+W
cHqtpWmdmS6eSg2ZPTkG2lPXOeT15Diim9oE0i7hN4Jesezc35AVvaurwvc1Ewln
COtHrRoA7K+7gDOZmbnvKR+52DVun+s5As6uQTSxNvsEt8zEbJe6Do3Hni0BVVvD
/KfrQOokZuoPRDTDQyk+NTqQEpYY77avj0jSzpZ+6FlNg6c0vcg0L2oMyul0xUnK
YzguqCSNfSgo5m5V/nVtt/YMvBwE92Xg5hz8O4Xpic10M6rVJWs/z/HxNmuqtFzq
teeZ8766I7hBUsuiPF+0YO+YaAO4CwCugRLNtIg9GF6QCxKEEMMSjtui24Ef87qs
QIX9Y+dCs2ru+CJMqeQF
=buTC
-----END PGP SIGNATURE-----

--zqSjrgky05FRiUsC--
