From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] bcm43xx: Fix code for spec changes of 2/7/2007
Date: Wed, 14 Feb 2007 13:52:05 +0100
Message-ID: <1171457525.11116.19.camel@johannes.berg>
References: <45cca236.+lL/rsW3DbM3elnk%Larry.Finger@lwfinger.net>
	 <45CCBB93.2040703@lwfinger.net> <45CCC5DF.8010001@gentoo.org>
	 <200702092017.36950.mb@bu3sch.de>  <45CCD1B1.80709@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-iRi5Bsnp2qHUeP8HNPBk"
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Larry Finger <larry.finger@lwfinger.net>,
	linux-wireless@vger.kernel.org, Bcm43xx-dev@lists.berlios.de,
	John Linville <linville@tuxdriver.com>
To: Joseph Jezak <josejx@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:50871 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932445AbXBNTET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Feb 2007 14:04:19 -0500
In-Reply-To: <45CCD1B1.80709@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-iRi5Bsnp2qHUeP8HNPBk
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-02-09 at 14:55 -0500, Joseph Jezak wrote:

> Well, here's the problem.  There are a few places where a value is=20
> changed (different value written to a register).  Does this mean=20
> that the value is different due to the uCode changes (can't tell, no=20
> documentation)?=20

=46rom what I've seen in the ucode that question isn't really too hard to
answer: as long as it's not in the shared memory or ucode register space
the ucode can't really have an influence.

>  Is it applicable to all revisions (can't tell, some=20
> revisions are not supported in this version)? =20

Best bet would be to make it conditional right now and have someone test
for these cases with older hw.

> If the revision=20
> number range in a check changes is that because of a difference in=20
> supported cards or a bug fix?

Hmm. Same I guess, use the new check for new hw and the old check for
old hw, i.e. assume it's the former and not a bug fix (until tested
otherwise.)

I think our best bet is to treat the older hw the same as the older
driver does.

A bigger problem, IMO, is that we'd have to support all the older
microcode things which is a bit tricky since things in shm have moved a
lot... Maybe we should find a third maintainer who has access to a
couple of old cards :)

johannes

--=-iRi5Bsnp2qHUeP8HNPBk
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF0wX1/ETPhpq3jKURAg11AKCeSHViazpI9Y7AHodHHTCXYPBReQCdFHy4
j4z9ZNRme/H29BscD7iy9C8=
=l1Jt
-----END PGP SIGNATURE-----

--=-iRi5Bsnp2qHUeP8HNPBk--

