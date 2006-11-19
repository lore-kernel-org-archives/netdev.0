From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 7/13] d80211: add a perm_addr hardware property
Date: Mon, 20 Nov 2006 00:20:18 +0100
Message-ID: <1163978418.9216.4.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163963898.15473.36.camel@johannes.berg>
	 <1163964556.15473.53.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-LBo01Q6S8dPSAaFNy1vN"
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
Received: from crystal.sipsolutions.net ([195.210.38.204]:2275 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S933708AbWKSXWH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 18:22:07 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1163964556.15473.53.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-LBo01Q6S8dPSAaFNy1vN
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2006-11-19 at 20:29 +0100, Johannes Berg wrote:

> +	memcpy(ndev->dev_addr, local->wiphy.perm_addr, ETH_ALEN);

> +	memcpy(local->mdev->dev_addr, local->wiphy.perm_addr, ETH_ALEN);

ugh, somehow I messed up. that should be local->hw.perm_addr of course.
Same in patch 8.

johannes

--=-LBo01Q6S8dPSAaFNy1vN
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFYOay/ETPhpq3jKURAilLAKC3yD1tElReqhME3BxQgqbxeFUlhgCbBsh9
HsQ9ItuJaLGtuykgBnFRvt8=
=+j4P
-----END PGP SIGNATURE-----

--=-LBo01Q6S8dPSAaFNy1vN--

