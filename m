From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] d80211: Fix inconsistent sta_lock usage
Date: Sat, 06 Jan 2007 17:52:57 +0100
Message-ID: <1168102377.5207.59.camel@johannes.berg>
References: <45996CBA.8020307@web.de>
	 <a32f33a40701020730n773d7ed8pe99d98ecc7b96a0e@mail.gmail.com>
	 <20070102162201.GA28457@infradead.org>
	 <200701052108.40185.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Nq9LyxPnq+XEd7SYUte1"
Cc: Jiri Benc <jbenc@suse.cz>, Jan Kiszka <jan.kiszka@web.de>,
	Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:47218 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbXAFQxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jan 2007 11:53:34 -0500
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200701052108.40185.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Nq9LyxPnq+XEd7SYUte1
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-01-05 at 21:08 +0100, Ivo van Doorn wrote:

> This patch uses the __set_bit and __clear_but as suggested by Christoph.
> It also removes the local argument since it was unused.

NACK. This breaks spec compliance for drivers that use the TIM in their
beacon frames.

johannes

--=-Nq9LyxPnq+XEd7SYUte1
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFn9Pp/ETPhpq3jKURAuqJAJ9aat4gGu3dQPWEuN34vdD8s9IijACglONJ
qbQlerXj8m9sZk5JFc/zlNI=
=xU96
-----END PGP SIGNATURE-----

--=-Nq9LyxPnq+XEd7SYUte1--

