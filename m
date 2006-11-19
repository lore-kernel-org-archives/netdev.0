From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] d80211: fix scan issues with new ops
Date: Sun, 19 Nov 2006 17:35:30 +0100
Message-ID: <1163954130.15473.18.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163895673.15473.11.camel@johannes.berg> <200611191715.34225.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-5i7IIQddD7i8V+BlDGJE"
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Ivo van Doorn <ivdoorn@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:30889 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1756771AbWKSQh3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 11:37:29 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200611191715.34225.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-5i7IIQddD7i8V+BlDGJE
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2006-11-19 at 17:15 +0100, Michael Buesch wrote:

> > -	if (local->ops->hw_scan) {
> > +	if (local->ops->hw_scan && local->wiphy.flags & IEEE80211_HW_SCAN) {
>=20
> Please wrap this into ()

Good point :)

johannes

--=-5i7IIQddD7i8V+BlDGJE
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFYIfS/ETPhpq3jKURAmoLAKC6pgEBWu/ElDvAjRNESzI2vUNqrwCgoN7a
sbZMvOgpPw81KQaWLUtmXno=
=4qvU
-----END PGP SIGNATURE-----

--=-5i7IIQddD7i8V+BlDGJE--

