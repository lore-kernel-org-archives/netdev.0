From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH v2] net: cadence: Add architecture dependencies
Date: Wed, 23 Apr 2014 15:23:08 +0100
Message-ID: <20140423142308.GC12304@sirena.org.uk>
References: <20140414153849.7138699b@endymion.delvare>
 <20140422203209.GH12304@sirena.org.uk>
 <535768E1.8050609@monstr.eu>
 <20140423094010.17d2d763@endymion.delvare>
 <5357897B.6020105@monstr.eu>
 <20140423124838.37aa0759@endymion.delvare>
 <5357A0A1.1020600@monstr.eu>
 <20140423113402.GV12304@sirena.org.uk>
 <5357BD14.1000608@monstr.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="y9nWygwVi89jFPus"
Cc: Jean Delvare <jdelvare@suse.de>, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Fengguang Wu <fengguang.wu@intel.com>
To: Michal Simek <monstr@monstr.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:42956 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752503AbaDWOXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 10:23:33 -0400
Content-Disposition: inline
In-Reply-To: <5357BD14.1000608@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--y9nWygwVi89jFPus
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Apr 23, 2014 at 03:16:04PM +0200, Michal Simek wrote:
> On 04/23/2014 01:34 PM, Mark Brown wrote:

> > Distro maintainers like Jean are complaining about build times for their
> > kernels if they enable absolutely everything so if they're never likely
> > to see any hardware using something they want to skip it.

> Is there any reasonable solution for this?
> 1. One group is saying use COMPILE_TEST for every driver to have better
> coverage.
> 2. Next group is saying I don't want to build everything for my arch.

> Fixing Kconfig to say !x86 is probably not the right way to go.

> Isn't it enough not to enable absolutely everything?

You're misunderstanding - the discussion here is for the !COMPILE_TEST
case.  Nobody wants to hide things in the COMPILE_TEST case, it's about
what happens when that's disabled for production kernels.

--y9nWygwVi89jFPus
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJTV8zJAAoJELSic+t+oim9vaUP/1ptXn73Z97IwA3OxVLf3QBH
pObS5pbPPm4cAthOHkNLP92HdegQd20i/OuWC5f9CcoVnRtapP67cVhA0ZPTWh99
4PSLN90iMaXhE7wDtF/iIxZttDSn40IfXk/2qCx6PA0AoQmSKueDfRHcmq5yr+/n
bGSIeo7V/27+XfmQGX/35shvsDTHlXc09zx9VHluXEr6GPLBgUBshxFAGQbTFr3L
uJxwwjd4x/xFxKJr/T/NXA93m1IeLahTK4JWgW5P53pqTTVfFrT2SbgRIoogE7AU
qkP9Q2sUnrbvWe4r2rVRytcmgPOGxkJfhuylB1IpiwH6FppDFLYhyNDMyir02kGJ
xCS1lSsgS+ZnBxphWiKU3QXFzfK2UAD8CaYepGjwPvoPT1H2QI1jq5bDC7uSO0jL
kXR/7pT90IXxaFHfjcgFpKoymxDUg9KWcoUySEHkv81G+mepzTDbnNOCAnkY16sP
VAt/0IKVvjse6RbpdIo7pFc8zgx6aVHxCp6SXz3EGTmIM5kzqBJpz8kby/tHvrQi
20O+Aw5CSn5dC0Xz+DwLGc+ynLZJS4Z78k8K9SYFIdjZvBu8tG1Va5l2dwd0jYHT
FdBcYN/WeYBSMMjbd9aSe12BgUbqBIyd4t/aA/N/r/JLJFtYe3YyA7N3Q9jSlZaq
t40jsOg8KWfNsIRE1sAh
=rKoy
-----END PGP SIGNATURE-----

--y9nWygwVi89jFPus--
