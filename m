From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] d80211: Fix inconsistent sta_lock usage
Date: Sat, 06 Jan 2007 18:01:21 +0100
Message-ID: <1168102881.5207.63.camel@johannes.berg>
References: <45996CBA.8020307@web.de>
	 <a32f33a40701020730n773d7ed8pe99d98ecc7b96a0e@mail.gmail.com>
	 <20070102162201.GA28457@infradead.org>
	 <200701052108.40185.IvDoorn@gmail.com>
	 <1168102377.5207.59.camel@johannes.berg>  <459FD5B5.2050706@web.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Mrv1ebU2OTjFJ09MtuT3"
Cc: Ivo van Doorn <ivdoorn@gmail.com>, Jiri Benc <jbenc@suse.cz>,
	Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:58100 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439AbXAFRCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jan 2007 12:02:06 -0500
To: Jan Kiszka <jan.kiszka@web.de>
In-Reply-To: <459FD5B5.2050706@web.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Mrv1ebU2OTjFJ09MtuT3
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2007-01-06 at 18:00 +0100, Jan Kiszka wrote:
> Johannes Berg wrote:
> > On Fri, 2007-01-05 at 21:08 +0100, Ivo van Doorn wrote:
> >=20
> >> This patch uses the __set_bit and __clear_but as suggested by Christop=
h.
> >> It also removes the local argument since it was unused.
> >=20
> > NACK. This breaks spec compliance for drivers that use the TIM in their
> > beacon frames.
>=20
> Bit ordering, I see. Then go for my original patch + comments why this
> is open-coded in __bss_tim_set/clear + removed unused arguments from
> those functions, OK?

Sounds good to me, care to send a new patch?

johannes

--=-Mrv1ebU2OTjFJ09MtuT3
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFn9Xg/ETPhpq3jKURAu73AJ97b+tJkWwv6TTKXoxye7kJOfzAdACeLflt
Xlh2C+DyelRIm1U01gCwuMM=
=ggBb
-----END PGP SIGNATURE-----

--=-Mrv1ebU2OTjFJ09MtuT3--

