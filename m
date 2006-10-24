From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] [PATCH 1/3] adds iso3166-1 support
Date: Tue, 24 Oct 2006 18:08:14 +0200
Message-ID: <1161706094.3942.24.camel@johannes.berg>
References: <43e72e890610231545n389d8a6dy89bb476101953234@mail.gmail.com>
	 <1161678617.2840.5.camel@ux156>
	 <43e72e890610240859o39a42658p64d198a2130e3f87@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-wCWqbU5bcYChSRg9Ba38"
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:23701 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030412AbWJXQJe
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 12:09:34 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <43e72e890610240859o39a42658p64d198a2130e3f87@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-wCWqbU5bcYChSRg9Ba38
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2006-10-24 at 11:59 -0400, Luis R. Rodriguez wrote:

> also if we index based on alpha3 we get O(1)
> access to the elements. Will make these changes.

I wouldn't do that, it's bound to make the array size explode because
there'll be one country starting with A and one starting with Z.
Probably better to do a binary search and make sure (by hand) it's
sorted.

johannes

--=-wCWqbU5bcYChSRg9Ba38
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUART46baVg1VMiehFYAQLzrw/5ARqQHi4kAXcYncRy9wET28LbSmJ86cwH
B0gzhBVUf0dN9i5yMlj54n/aAhC8l5ceKABce2Z40AyzGiIBs5BcR79vlPw/4aek
dXWUH3jTd1VsYbJqx9Z0ezhStFyOs3ozK8MYdhyoxHHpRf7qkZQEClNazSOyglWP
MTcEax11hZJblHs0GECxaoHTqYv3xruBg8i2WT851TVMid6lc+Ug0bC4HuYzCly+
9MKSkwtoKr9wyA2yBN2xDVpvE7NjATXTuOWmV3Sqko5M/FXXYotrU//qgI8/sCJP
IuDqab9StlQMGlnGouq6lj4oulf2M8AKj/HZ7LfVs9p+AD1FvJ5XEeIFhoimUGCy
o8fXsbOKM78uh0IrQf7J6d6U3Oqxm5eA3YwBBPcgtgb1Toqyt8biA/eLR6vXQcuO
sNwAn0AqpF/bFKUtbczAnQQ1E7T+p+BvJYLSgpRLu7fVbFgcXwCvuyT/VUvhN9Hk
pku8hHOpY3YXvOYXgIkPis6vgURGu3gC0buFwMON70LejBaomYzR9p9i3xe5I5KU
Wl/Hh9wxpXs1UkW5KGsRWDA2J+BvfPcEtW4dC274wkTlIZhfK1KNf8M60+fKcjr5
QXdol9PK04m2BhK7C0KIcLts+jvGavhRQneV3m+AC+Nj4F1N2w/2YXOMkTLaKIFL
LmI9Uru9scg=
=BGYL
-----END PGP SIGNATURE-----

--=-wCWqbU5bcYChSRg9Ba38--

