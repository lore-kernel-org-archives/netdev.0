From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 0/13] move d80211 away from netdev towards wiphy
Date: Sun, 19 Nov 2006 20:18:18 +0100
Message-ID: <1163963898.15473.36.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-AfyHJ3KN0gEU8A9pikbi"
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:63624 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S933046AbWKSTUI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 14:20:08 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1163802439.3392.47.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-AfyHJ3KN0gEU8A9pikbi
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

This is a repost of the whole patchset modified according to various
comments.

I've folded patches 6, 7 and 8 into one driver API update patch that is
smaller than the three combined. Unfortunately, it's still very large.
I've also changed the introduction of ieee80211_wiphy, in fact the patch
doesn't introduce it at all it just moves some stuff into ieee80211_hw
and the operations out of it.

johannes

--=-AfyHJ3KN0gEU8A9pikbi
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFYK36/ETPhpq3jKURAqsQAJsHCq41mgZ0cBSv8v+kaxdVmjD/sACeNF4U
gNWs28yOTZP2lCEwlkArZHw=
=cacg
-----END PGP SIGNATURE-----

--=-AfyHJ3KN0gEU8A9pikbi--

