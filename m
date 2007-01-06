From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] d80211: Fix inconsistent sta_lock usage
Date: Sat, 06 Jan 2007 17:59:23 +0100
Message-ID: <1168102763.5207.61.camel@johannes.berg>
References: <45996CBA.8020307@web.de>
	 <a32f33a40701020730n773d7ed8pe99d98ecc7b96a0e@mail.gmail.com>
	 <20070102162201.GA28457@infradead.org>
	 <200701052108.40185.IvDoorn@gmail.com>
	 <1168102377.5207.59.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-sKnrLjYXCbQzxc5XxGMX"
Cc: Jiri Benc <jbenc@suse.cz>, Jan Kiszka <jan.kiszka@web.de>,
	Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:36000 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbXAFQ77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jan 2007 11:59:59 -0500
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <1168102377.5207.59.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-sKnrLjYXCbQzxc5XxGMX
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2007-01-06 at 17:52 +0100, Johannes Berg wrote:
> On Fri, 2007-01-05 at 21:08 +0100, Ivo van Doorn wrote:
>=20
> > This patch uses the __set_bit and __clear_but as suggested by Christoph=
.
> > It also removes the local argument since it was unused.
>=20
> NACK. This breaks spec compliance for drivers that use the TIM in their
> beacon frames.

Which, in fact, is the only point we keep track of the TIM, note that we
never actually test if bits there are set, the stack has better ways of
keeping track of the pending traffic.

johannes

--=-sKnrLjYXCbQzxc5XxGMX
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFn9Vr/ETPhpq3jKURAj1/AKCOH3V8Wppd4PEg4NxtUjKBidRoEgCdEoUk
fGeXCvz5kmNsQx8xdqn64HA=
=c8o7
-----END PGP SIGNATURE-----

--=-sKnrLjYXCbQzxc5XxGMX--

