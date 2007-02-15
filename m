From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] bcm43xx: Fix code for spec changes of 2/7/2007
Date: Thu, 15 Feb 2007 17:53:33 +0100
Message-ID: <1171558414.5220.38.camel@johannes.berg>
References: <45cca236.+lL/rsW3DbM3elnk%Larry.Finger@lwfinger.net>
	 <200702142240.01494.mb@bu3sch.de> <1171552024.5220.4.camel@johannes.berg>
	 <200702151613.20746.mb@bu3sch.de> <1171552753.5220.10.camel@johannes.berg>
	 <20070215165125.GA3328@tuba>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ixetdB7HSC5Ef1SeqAgJ"
Cc: Joseph Jezak <josejx@gentoo.org>,
	Matthew Garrett <mjg59@srcf.ucam.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Bcm43xx-dev@lists.berlios.de,
	Larry Finger <larry.finger@lwfinger.net>
To: Martin Langer <martin-langer@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:47754 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966134AbXBOQxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Feb 2007 11:53:42 -0500
In-Reply-To: <20070215165125.GA3328@tuba>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ixetdB7HSC5Ef1SeqAgJ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-02-15 at 17:51 +0100, Martin Langer wrote:

> Yep. We have all kinds of firmware with the new instruction set. It's=20
> only ucode2 (old instruction set) that's missing. But the later ucode4=20
> which also uses the old instruction set is available in v4.
> OTOH, ucode13 isn't available in v3. We can't offer one firmware version=20
> for all card revisions. Both are limited to a specific range of=20
> revisions.
>=20
> v3	rev2...rev12
> v4	rev4...<=3Drev13

The upper limit doesn't really matter, afaict the effect of running a
rev9 instead of rev13 will just be a missing performance increase due to
bigger FIFOs not being used fully.

johannes

--=-ixetdB7HSC5Ef1SeqAgJ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF1JAN/ETPhpq3jKURAqVJAKCnFvCiiaKyXfSRQbCV9tMMsvibOACcCMi2
mmz7ezitDj0vitNkO+yytAQ=
=btJr
-----END PGP SIGNATURE-----

--=-ixetdB7HSC5Ef1SeqAgJ--

