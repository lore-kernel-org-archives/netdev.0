From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 5/5] d80211: allow wireless vlan interface to have same
	MAC an AP interface
Date: Sun, 08 Oct 2006 23:32:08 +0200
Message-ID: <1160343128.4701.6.camel@johannes.berg>
References: <20061003181118.537800000@devicescape.com>
	 <20061003181233.GE19403@devicescape.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-oqMO/0n0p7Y5AlSW8gCA"
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:21416 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751447AbWJHVeN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Oct 2006 17:34:13 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061003181233.GE19403@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-oqMO/0n0p7Y5AlSW8gCA
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2006-10-03 at 11:12 -0700, David Kimdon wrote:
> Wireless vlan interfaces need to have the same mac address as
> AP interfaces.  The STA must not see the change when it is bound to
> a specific vlan, so the address of the vlan interface must be the same
> as the address of the AP interface the station associated with.

Hm. Now I finally understand the vlan interface type. Neat. How do you
bind stas to one vlan interface? Is it possible to do on the fly after
EAP or similar?

Anyway. Wouldn't it make more sense to not even allow setting a MAC
address different from all AP interfaces, i.e. require that the VLAN
interface have the same MAC as one of the AP interfaces that exist?

And then there probably should be a check that prohibits binding a sta
to a vlan interface that has a different MAC than the AP interface it
is/was on... or something.

johannes

--=-oqMO/0n0p7Y5AlSW8gCA
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARSluV6Vg1VMiehFYAQJJLQ//Y+geD0S1n9xNxTOXeO1lvRA3nAc0gD0D
NVdcQjnqYatfGP/dEjCKBd0TuEL1284ZddXpK6XLFa19/gmDrjk71m8j6EAzdLym
sMa/OY6h78hk/lHj0+QOgkIMeu2r6D1Lv5kWOwfR7KD1yvLZYxOUVKLRi3KDe6Ih
TS/1kFdMKu/ubenqh8cvjKB/NpoAPF6TClG4FcsF7doA5MJ3it9iDfTuNtH+f+i3
waTfhX5GPr8CZ4eH47+RDTqFsWz6fn1lKKuRM8NALGm60ZBcnBs1MSvCgLZZRPyq
8C9Lx0+g1BTwi2A9fyPYr7yu5M3WNa0p8xBBUmj/UU/Xn4ADW7aL/DDcWnAHNOEv
v4YPv0aahYpF8CfFmM3anRKrnQPwG+aGP3ZLIRfMkDjEdO+tR41+lkF1r4e3JR83
EvUhZXyXvg1AkNSaGvE6u4Cdd+lq5PMYBieM8WmwpcbadiwN+/CN7HQU5mIrDOCG
AwiJkcBd8uvZuF+2eXGrA90YOy3ZcbchnAXGNMo7Oa5t/N3QMUeFenGlXNKi+j3n
NMuxE08+VEPa9sL1uPLOKrA8OnePQn+0cN85zrnC7JCuDuEW9n4Z400vsyYZDc37
NgWnCkgel+p1Vj1J0oCI/LWSwR/3g627tM3Ex2Wrl3IBa5k2FU3ezKKL7Ttm1g32
SzsWa0qVpdM=
=2Ltr
-----END PGP SIGNATURE-----

--=-oqMO/0n0p7Y5AlSW8gCA--

