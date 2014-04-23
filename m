From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH v2] net: cadence: Add architecture dependencies
Date: Wed, 23 Apr 2014 11:04:42 +0100
Message-ID: <20140423100442.GK12304@sirena.org.uk>
References: <20140414153849.7138699b@endymion.delvare>
 <20140422203209.GH12304@sirena.org.uk>
 <535768E1.8050609@monstr.eu>
 <20140423094010.17d2d763@endymion.delvare>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cvXjSJHM7zN1D7qx"
Cc: monstr@monstr.eu, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:42484 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174AbaDWKFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 06:05:07 -0400
Content-Disposition: inline
In-Reply-To: <20140423094010.17d2d763@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--cvXjSJHM7zN1D7qx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Apr 23, 2014 at 09:40:10AM +0200, Jean Delvare wrote:
> On Wed, 23 Apr 2014 09:16:49 +0200, Michal Simek wrote:

> > > Cadence are an IP company,

> I can't parse this, sorry. What is an "IP company"?

They sell designs for blocks that can be used to build hardware rather
than physical objects or complete chips and they are independant of chip
vendors.  There are a number of other companies that do this, people
like Designware for example, and while ARM do obviously do architectures
they are also a generic soft IP company as well.  This means that for
those companies (and sometimes others) you can't assume that just
because it's used on some architecture that doesn't mean it's used on
others.

> > > might be worth having a FPGA
> > > Kconfig that architectures commonly deployed with lots of soft IPs can
> > > select and the IPs depend on rather than building a custom list for each
> > > IP.

> What are "soft IPs"? I'm afraid I wouldn't be able to translate your
> proposal into a patch, I just don't understand what you mean exactly.

Components used in the design of hardware sold by the above companies.
Several architectures (at least ARM, Microblaze and PowerPC) are
available in chips where most of the chip is a FPGA.

--cvXjSJHM7zN1D7qx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJTV5A3AAoJELSic+t+oim9+UoP/1QCqNxPPud2vOiITpUnalv8
Uhbwd7hsnxKpMVAyABr7ATBfgBSPJW2skuvxfWXdJGOE4AILhYVRgjSS0TcRSW5n
ZUenmSfKftkQTLIyIblb181tsTJbbhgbuT/3vT521r+sFtO2du1izjxA/Dy2rpah
UKLA4KzX/m5w+AaHrB+qFMjzNEDaxOAKOpyicSL7Nwya7/Px/JTotF+PGrGxrr7r
OhsTZpCFb9w39Xq/hfOov3S9AdBaqoqMbYtWkzWtcP7bZc7iH0Q8sX0DBKU7TRix
QtrMy7FFjRcRwPjI9dM9oKaYvHcG6W2P1qIeBmIRTaXVBpwvfl8r0HqefcHX5KYs
D0WKpAa9I+mTr9DqfS7NLiDQgrNV/2ioC2gLvzHuNWyxbQUuCpBImpQ6k+e2hNU1
qpRRZZKOInqhWAb9ZEyng9iFoHbvnE5g5NB3oR7CTl7i2u+gBFntYRxMX9c4HWdn
cA1xJLVQUBgwHB5yWpZYHr6NjhAdz5sZ0juwDiGHl7E3BoDmm6BU6skAHOruRZdb
15LzyRhqxJiBG+ndm0CIozLOeJLYuex34A2hYMeH5cSBgbqrBuX7E34GKcryK3rS
8FvR7lNpXuM+FnalsA+yFxwIqcQHsgweP19B/eKZ2+REdc80lAH0+iZsYZ0CaL/P
lCVnR0X+DQT2Xdf4cs0a
=dror
-----END PGP SIGNATURE-----

--cvXjSJHM7zN1D7qx--
