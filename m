From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/10] d80211: reduce mdev usage, fix ieee80211_rx_mgmt
Date: Sun, 19 Nov 2006 17:37:56 +0100
Message-ID: <1163954276.15473.21.camel@johannes.berg>
References: <20061119163545.GA25557@devicescape.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-3J7ZfgxyIkhjpuVJjPKI"
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:22954 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1756769AbWKSQjp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 11:39:45 -0500
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061119163545.GA25557@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-3J7ZfgxyIkhjpuVJjPKI
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > +	/* if no one will get it anyway, don't even allocate it.
> > +	 * unlikely because this is only relevant for APs
> > +	 * where the device must be open... */
> > +	if (unlikely(!local->apdev))
> > +		return;
>=20
> Why not just let it Oops and show the bug?  In what cases is it ok
> for apdev to not be set?

> Can we get whitespace changes like this in a separate patch?

Sure. I'll just remove it from this patch for now.

> again, so should we just let the Oops happen?

I'm thinking there might be race conditions where userspace does
something, then drops the ap device but after that some operations
complete and would lead to the oops too. Wasn't really sure.

johannes

--=-3J7ZfgxyIkhjpuVJjPKI
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFYIhk/ETPhpq3jKURAmYZAKCxMlnWP7RWObv1/FRPqpd48lkJhgCfYA1u
E8MSzRpD+H/RUwjJl/Nqrmg=
=8fqm
-----END PGP SIGNATURE-----

--=-3J7ZfgxyIkhjpuVJjPKI--

