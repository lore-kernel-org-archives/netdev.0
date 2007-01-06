From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] d80211: Fix inconsistent sta_lock usage
Date: Sat, 06 Jan 2007 17:52:18 +0100
Message-ID: <1168102338.5207.57.camel@johannes.berg>
References: <45996CBA.8020307@web.de>
	 <a32f33a40701020730n773d7ed8pe99d98ecc7b96a0e@mail.gmail.com>
	 <20070102162201.GA28457@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-38iMkWaPaSfGUBLepu+J"
Cc: Ivo Van Doorn <ivdoorn@gmail.com>, Jan Kiszka <jan.kiszka@web.de>,
	Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:47195 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbXAFQw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jan 2007 11:52:57 -0500
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20070102162201.GA28457@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-38iMkWaPaSfGUBLepu+J
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-01-02 at 16:22 +0000, Christoph Hellwig wrote:

> This really screams to be converted to __set_bit.

Whoops, I should really have jumped into this thread earlier but somehow
missed it.

This cannot be converted to __set_bit because the IEEE specs mandate
this format.

We can insert a comment that the format must stay like this :)

You have to realise that the TIM is sent as-is with the 0th bit
indicating multicast traffic (IIRC) and each of the other bits
indicating traffic for that AID.

johannes

--=-38iMkWaPaSfGUBLepu+J
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFn9PB/ETPhpq3jKURAr9XAKCzJwB3C4Ur0sk02UrxV9EyR9/S8ACbBR+g
0QyU6XWJQ3phfBaL0fGtZzw=
=PHDy
-----END PGP SIGNATURE-----

--=-38iMkWaPaSfGUBLepu+J--

