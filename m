From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: d80211 oops with bcm43xx-d80211
Date: Fri, 15 Dec 2006 16:26:16 +0100
Message-ID: <1166196376.3462.26.camel@johannes.berg>
References: <1166194587.3462.18.camel@johannes.berg>
	 <200612151623.07036.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-//TeFjf99MEev7JGsYNu"
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:56852 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484AbWLOPZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 10:25:57 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200612151623.07036.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-//TeFjf99MEev7JGsYNu
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2006-12-15 at 16:23 +0100, Michael Buesch wrote:

> It turns out to oops only sometimes for me.
> And if, then with some very strange looking oopses.

Yeah but that's probably because most of the stacktrace is from whatever
was running when the softirq was run...

> > the instruction c003030c is in the middle of tasklet_action and it's a
> > free-after-use type of thing as you can see from accessing 0x6b6b6b73,
>=20
> use-after-free?

yes, but the "use" is "trying to run tasklet"

johannes

--=-//TeFjf99MEev7JGsYNu
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFgr6X/ETPhpq3jKURAngiAKCQqSVdhMYALPgkqBG+FVyH5Qhs0ACeOBgf
tz5Gfcks+82awYRGPcQ2Fhs=
=YXh9
-----END PGP SIGNATURE-----

--=-//TeFjf99MEev7JGsYNu--

