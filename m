From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH v2] net: cadence: Add architecture dependencies
Date: Tue, 22 Apr 2014 21:32:09 +0100
Message-ID: <20140422203209.GH12304@sirena.org.uk>
References: <20140414153849.7138699b@endymion.delvare>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="iEmV301eZCZRjuW4"
Cc: netdev@vger.kernel.org, Nicolas Ferre <nicolas.ferre@atmel.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:41751 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757313AbaDVUcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 16:32:25 -0400
Content-Disposition: inline
In-Reply-To: <20140414153849.7138699b@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--iEmV301eZCZRjuW4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Apr 14, 2014 at 03:38:49PM +0200, Jean Delvare wrote:
> The Cadence ethernet chipsets are only used on specific ARM
> architectures. Add Kconfig dependencies so that drivers for these
> chipsets are only buildable on the relevant architectures.

Are you sure they're not used on any of the FPGA platforms like
Microblaze?  Cadence are an IP company, might be worth having a FPGA
Kconfig that architectures commonly deployed with lots of soft IPs can
select and the IPs depend on rather than building a custom list for each
IP.

--iEmV301eZCZRjuW4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJTVtHGAAoJELSic+t+oim9B7gP/2yZp8oFVJzwx/2Kp/MxYiMi
lFp9leQOEc5wzWysyMK+AH/FcJ5NLrm8fpfPWgpJHIFFuTyYrZ3O33Qj6fJYdeNm
pUcAgEh3bVEpbyjmqxqpKGJVFTNI/q0KiKQSkcjvLAyWtAHPBQxITEtSdTaKtmY+
avbE9Jnqpx7WPeaJSxrFAG4L7UOhjEQGSH91RSFeilIxQFhcQVyBbHlZ0DvjeiP7
m6JX80JJFLDC1+AquMQNfgmaN+QiReBC4Y0JO9roEfVlEYdNhpTm/FUGyWH3BzPC
bj6s9Yyhe69biAZPKP8FE8gs08qAqfqk09hxAY7ICq6xJiG2+ze4dfO4xr+e8Nhp
mzQ0Y8hZD9nZu+glITWos9tjvjKuCAYyixChcpJWf9I5aI6+GfZz/Sr7UKlWQifg
I5PcC2opGQkztFuVVZGFbg9h06VRr1AXbS1HRBEL62S3sh7fU14F6H8woTj3+TuP
UUBY+2mCn5azRaoRLQNaShz3RtnYfZlXqn1IeeWMOFfr3yQbS5lqh2RKZR1UUQJd
qDpLNqp2J7EhuCUZB98M2sTXS9XtccOad+INNX/918wba7pyYZFvG/DTIdMuULZo
Z/xQ5/OYrhoNrBZS2BgAuP1000HOsJD5CMvtUem8n6ej6IeLWV7VaShpHSrTCHJV
8sn5ExgTke34ABPEofdY
=CNTZ
-----END PGP SIGNATURE-----

--iEmV301eZCZRjuW4--
