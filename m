From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/6] d80211: add a struct device* hardware property
Date: Sat, 04 Nov 2006 00:21:14 +0100
Message-ID: <1162596074.24673.16.camel@johannes.berg>
References: <20061102223854.692274000@sipsolutions.net>
	 <20061102223854.692274000@sipsolutions.net> >
	 <20061102230015.555750000@sipsolutions.net> >
	  <200611031727.41131.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-+S4s+KdH8SJ92jL9S/96"
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	Ivo van Doorn <ivdoorn@gmail.com>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:33726 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932496AbWKCXWi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 18:22:38 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200611031727.41131.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-+S4s+KdH8SJ92jL9S/96
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2006-11-03 at 17:27 -0500, Michael Wu wrote:
> On Thursday 02 November 2006 17:38, Johannes Berg wrote:
> > +	/* hardware device */
> > +	struct device *dev;
> > +
> Can we just pass this in as an argument instead? No one is gonna look at =
it=20
> ever again after ieee80211_register_hw, so I don't think it's worth putti=
ng=20
> in struct ieee80211_hw.

Actually, it is used for all new devices as well. Yeah, we could pull it
out of the mdev again, but it feels stupid to go to so many
indirections. The code is already barely understandable. I had a hard
time cleaning up the places where struct net_device * is passed, but the
only thing it's ever used for is deref'ing ->ieee80211_ptr to get local.

> > +	local->mdev->class_dev.dev =3D hw->dev;
> Why not use SET_NETDEV_DEV?

You're right, it should use that.

johannes

--=-+S4s+KdH8SJ92jL9S/96
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIUAwUARUvO6aVg1VMiehFYAQKPEQ/2Ji74CYUDPAo6mwTBDDt4HNWN8dfyhCYL
8l7yw08fBixuTs1Qou2y7rmiV3aZL71VjmPc6INlng/Q2a1MP1xM52pXwOVvja/b
jRyjGyNqzHxSrtzqjKx9KvbxVKMkoiuTpctAbYuyeBRBFvP3gChbdn2AFTz/geHG
VGLhkZACMpJ9rBS9awoAZVxK633Y+OE0CxYGutE6KhDtWYjenIOx6JYEvEIoA32q
t0OQ9ONnoKmxsXl67/dgTH0iLPC2pMO59hnw5671Cu3prqC1bpWY36mTwsifG71A
5xNpZ6EDF9gfxg+phgbbCMFvkQCzF4WBFPgm/APGC15WnS5qIzJD7S+zXNb7acsP
ndj0HhBPy4ajkHgMXPJYNOiKpt+NRxmZz5f0uNwgx7HOprCSnvlFr4pmVE35WJPM
PDRNM9O2iWq2+jOeHCgqxlGN3fZvbNJrvO6GaTGOj6YX9xU7DCxlBhk+URvAunKh
YBkAETOTXt6c6zx276gOScy0P0HRBt4HlE4X964lvmRMzwa55G7Z+jpi5LdtKklg
QneE9K8QRrpyQyg4uYg5dqadCt9EdApPgACzMHey1m3ncudmNnS9MUYYaS1eiElq
D5fXYJTL5LoGorT/TB6WY9xM2JmYO6QeyXNmWeJ/PyUMeFZhNSQ7FosJ7s7v41KF
gZnA83EZaA==
=l/jg
-----END PGP SIGNATURE-----

--=-+S4s+KdH8SJ92jL9S/96--

