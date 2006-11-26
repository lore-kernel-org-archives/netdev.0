From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] softmac: remove netif_tx_disable when scanning
Date: Sun, 26 Nov 2006 19:40:36 +0100
Message-ID: <1164566436.22909.26.camel@johannes.berg>
References: <4568DCEB.mailLLK1Z24PM@lwfinger.net>
	 <45691273.9090803@gentoo.org> <1164535408.21459.3.camel@johannes.berg>
	 <4569C2D0.8080406@gentoo.org> <1164559882.22909.5.camel@johannes.berg>
	 <4569DC33.8050208@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-pZljQR6W1uaqZJsvflH2"
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	Stefano Brivio <st3@riseup.net>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:34449 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S935516AbWKZSml
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Nov 2006 13:42:41 -0500
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <4569DC33.8050208@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-pZljQR6W1uaqZJsvflH2
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2006-11-26 at 13:25 -0500, Daniel Drake wrote:

> No, we could stick with our existing setup if the stack did something=20
> different.

But you do need full refcounting I guess.

> > Because for
> > the stack it wouldn't be required if it'd simply not start scanning whe=
n
> > queue is disabled and stop scanning immediately when queue stop is
> > requested.
>=20
> That would work, assuming there is a way to make the stack listen for=20
> the "TX queue stopped" event (or would the ieee80211_tx_disable wrapper=20
> take care of that?).

A wrapper is what I had in mind, I don't think there's any notification
for these things.

johannes

--=-pZljQR6W1uaqZJsvflH2
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFad+j/ETPhpq3jKURAjkhAKCuU9ToY3T0FqTelMjhwUvfaQXegQCdHZTM
vRHuGSDlUKimwGPplIMGmoA=
=7G2/
-----END PGP SIGNATURE-----

--=-pZljQR6W1uaqZJsvflH2--

