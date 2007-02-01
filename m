From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/6] d80211: don't display name of invisible network
	device
Date: Thu, 01 Feb 2007 16:19:15 +0100
Message-ID: <1170343155.22420.5.camel@johannes.berg>
References: <20070129174809.6401B48499@silver.suse.cz>
	 <1170164845.30318.19.camel@johannes.berg>
	 <58d0dbf10701300600h24cdb9b8xabbc27b16d4ddb05@mail.gmail.com>
	 <1170269938.2236.1.camel@johannes.berg>
	 <20070201161711.37373b18@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Z6Zp15RiSRzwoa0kLZen"
Cc: Jan Kiszka <jan.kiszka@googlemail.com>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
To: Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:36420 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161177AbXBAPUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 10:20:30 -0500
In-Reply-To: <20070201161711.37373b18@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Z6Zp15RiSRzwoa0kLZen
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-02-01 at 16:17 +0100, Jiri Benc wrote:
> On Wed, 31 Jan 2007 19:58:58 +0100, Johannes Berg wrote:
> > Well, that's a bug indeed, but the cure isn't "don't allow any qos
> > operations" but rather "don't allow removal of the 802.11 qdisc".
>=20
> This solution can be described as "don't allow 802.11 qdisc
> customization for now, introduce that as a new feature later when
> qdiscs and netdev are not tied together".

Ok, that makes sense.

> It solves several problems by stripping down just one feature (which
> hardly anybody uses now and which is not working properly anyway) which
> will be reintroduced later. Quite feasible I would say given the fact
> that userspace-visible master network interface is perceived as a merge
> blocker by some people.

Alright. Fine with me :)

johannes

--=-Z6Zp15RiSRzwoa0kLZen
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFwgTy/ETPhpq3jKURAmGPAJ9r29t0OlGYt+FJh+Sb3G63sXDQwwCeO8Le
V7WKfbRxszAi9mijEZHUj2Q=
=qi3B
-----END PGP SIGNATURE-----

--=-Z6Zp15RiSRzwoa0kLZen--

