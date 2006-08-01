From: Johannes Berg <johannes@sipsolutions.net>
Subject: 802.11/crypto questions
Date: Tue, 01 Aug 2006 07:40:52 +0200
Message-ID: <1154410852.17333.4.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-bPnA9ExnIe+uI/1L//jM"
Cc: Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:58521 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1161475AbWHDVXi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 17:23:38 -0400
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-bPnA9ExnIe+uI/1L//jM
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

Since there's been lots of talk about multi-STA or multi-BSSID devices
(more than one client, more than one AP on the same PHY) and I was just
looking into some crypto stuff on bcm43xx, it got me wondering.

The bcm43xx has an elaborate group key matching thingie which will be
useful if it's all WPA2, but if it's say just plain WEP, then that is a
problem since you'd either need to use the same keys or disable the
bcm43xx crypto hardware.

Hence, I suppose the question really is -- does the dscape stack allow
changing the 'sw crypto needed' flag on the fly?

johannes

--=-bPnA9ExnIe+uI/1L//jM
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARM7pYqVg1VMiehFYAQJO8w/7BraBIpPTBBG0bf1Thqho2UItb5I8qlUo
6Q9MdASyL4VMR3vc3D1yaG/t1YuyKBoBxRZktwncOos2ZNmmn8PmQtqkm2kGu26R
QgxAa61/U8sXcD1LH2jBgaVT0TooVU0AhO1bLzQ6QcQVFvL8fjY6eUACI4nzFLZH
i9GJdPJUcB5aQLC+tINxXyMyHg/cuF2UdFeJTTa6y8AqziJyyTq/qGzIGZu1BMr+
/cOm9Vgaww+M5Z0egMMgz1fVv5bhqdMmzPs/J/nyKXLGrQXbIrlZqJMz0JUBmKYM
qbu5P3L097cfLBraLGmC2dBhG26wg9Sj6htbGwW9duAdDyWOrl6vTztPjStdDpnm
uyr7AdOTq6fPyPwbqeH/lUAMzfqOmsQAgEtbYyzVdvk+NxbIPo8U+/bmqhe/hRPQ
+HTrG5kgUexRxk9XbGXgtD+8a5KrJLlJ5cIUoqAsd2+Kq0F9DqcuA//Pm5Oe4Bbt
UA3mBpU/t5+tDRZsTWH/ZJ/luiB/sKepyZNRHvuJ8W36c4HJtsXJ59qS/4jBhNcv
Da17KfZSlzgJNTvmI2CkcsnnO2y49DqSjgwD4825biphYqv62ekWa0Xh8fuAK2nG
WIjvTd+kLdYVqyAmHEwXC9P5s7yBRhC3YZsA/+GgOXWbfhhvGzuevbuKCUdHyEf9
I7wXRkx+uCc=
=zta9
-----END PGP SIGNATURE-----

--=-bPnA9ExnIe+uI/1L//jM--

