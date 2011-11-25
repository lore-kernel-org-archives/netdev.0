From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net] net: Revert ARCNET and PHYLIB to tristate options
Date: Fri, 25 Nov 2011 14:07:51 +0000
Message-ID: <1322230071.2839.337.camel@deadeye>
References: <1322119410.2839.262.camel@deadeye>
	 <20111125.013102.841551383223873520.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-cBsg8b4a/4Tmrks708oE"
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	debian-kernel@lists.debian.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58439 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754214Ab1KYOIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 09:08:10 -0500
In-Reply-To: <20111125.013102.841551383223873520.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-cBsg8b4a/4Tmrks708oE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-11-25 at 01:31 -0500, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Thu, 24 Nov 2011 07:23:30 +0000
>=20
> > Commit 88491d8103498a6166f70d5999902fec70924314 ("drivers/net: Kconfig
> > & Makefile cleanup") changed the type of these options to bool, but
> > they select code that could (and still can) be built as modules.
> >=20
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> > ---
> > I consider the inability to build arcnet.o and libphy.o as modules to b=
e
> > a regression in 3.2 for general-purpose distribution kernels.
> > Therefore, please apply this to the net tree.
>=20
> I challenge you to get PHYLIB set to 'm' in a configuration such as
> "allmodconfig" which is clearly in line with the kind of configuration
> which "distribution kernels" use.
[...]

Well, I can't think why it would be built in, since PHY modules can be
auto-loaded now.

$ grep PHYLIB /boot/config-2.6.32-5-amd64=20
CONFIG_PHYLIB=3Dm
$ grep PHYLIB /boot/config-3.1.0-1-amd64=20
CONFIG_PHYLIB=3Dm

Ben.

--=20
Ben Hutchings
Teamwork is essential - it allows you to blame someone else.

--=-cBsg8b4a/4Tmrks708oE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATs+hN+e/yOyVhhEJAQpzmg//RpxM6dRATvD3cPkst6bLgV9KCGIMQB/g
XVjYP0pag1vFoRZGUcUXmQcDEI/UCO4FS74LNR2sZxW/8a/XE7ULP0oKfIaGzaMf
hb2Q7YnagyK7weaKrS7KZwtdLVvquqO37sirmztQQJsXuBEZ/R9awRufH7qt9ZB3
SAnaixf6EetiNyfQCn86t6JcRhy9KoesePxs4gPZurPMpUXlsJNF5KD7zIO4xQ4u
JxYJfzDM5mHPS5C6Brawl2+DJHp1UIcBnhe5VdNs50Fh2TpQAiwqtKW0+d0TH6Wb
Q37cvv9E0jj1yRhTuiEf3arhxg+paeYZXWd4nEse0+JEujzCgDitUVIN2h6RoBGd
AuAWXwAPFri8oGXXDByXFQhsrOxoSJbhpzmr7UHi25l0qsBcxTrBThofiPDgHmud
0BAt1qk13Scb61tJHtf3UZl5nf61/0dkhNzQCtjzGyjZMOI6TpDxJT8W7JbyRCY1
lsmkbYJvx2prMg8BR69TShv8qhQWOaES6FT6d1H7i/HBEsL0X/bm4EgJnTsOr7Fs
g0/sA1lCo6yyy3yral4Os0vSoHm6DlidkApMIPWJF58PpKGI8nUbBPAjowmZeabH
MBO3qTGylS5ZzSEUMl6gQDB2QGJcXR086cq8RH2o13epSVL+6Z4jHJKeFSWo1Y1q
XsBL6Gr+qXs=
=o7Zu
-----END PGP SIGNATURE-----

--=-cBsg8b4a/4Tmrks708oE--
