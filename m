From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/10] d80211: reduce mdev usage, fix ieee80211_rx_mgmt
Date: Mon, 20 Nov 2006 18:55:00 +0100
Message-ID: <1164045300.9216.17.camel@johannes.berg>
References: <20061119163545.GA25557@devicescape.com>
	 <1163954276.15473.21.camel@johannes.berg>
	 <20061120184438.5fabfb43@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-vjm5Or6+571+ZNgae22u"
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:43982 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S966297AbWKTR4v
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 12:56:51 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061120184438.5fabfb43@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-vjm5Or6+571+ZNgae22u
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2006-11-20 at 18:44 +0100, Jiri Benc wrote:
> On Sun, 19 Nov 2006 17:37:56 +0100, Johannes Berg wrote:
> > I'm thinking there might be race conditions where userspace does
> > something, then drops the ap device but after that some operations
> > complete and would lead to the oops too. Wasn't really sure.
>=20
> Yes, that's possible. But your check doesn't solve it.

Oh. Right, there are no locks involved :)

We want to get rid of the management interface so I guess we shouldn't
try to fix the locking with this since we get it for free when we
correctly implement it in cfg80211.

johannes

--=-vjm5Or6+571+ZNgae22u
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFYev0/ETPhpq3jKURAsIoAKCjuUbOu5fJXaoY2CKEk6XDIRoPfwCdFckO
uU0TcYruhqzIjP7jAc05kHc=
=tc3N
-----END PGP SIGNATURE-----

--=-vjm5Or6+571+ZNgae22u--

