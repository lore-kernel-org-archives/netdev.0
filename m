From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH 0/4] d80211: some header cleanups
Date: Sat, 9 Dec 2006 03:08:33 -0500
Message-ID: <200612090308.45914.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4196594.RzlAkqy5Id";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:59287 "EHLO
	server8.tchmachines.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936134AbWLII3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Dec 2006 03:29:50 -0500
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4196594.RzlAkqy5Id
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

This patch series implements parts of the 802.11 header cleanup suggestion=
=20
(http://www.spinics.net/lists/netdev/msg12124.html).

It moves the general 802.11 stuff out of net/d80211.h and into the new=20
linux/ieee80211.h. d80211_shared.h is merged into d80211.h. d80211_mgmt.h i=
s=20
merged into linux/ieee80211.h. Finally, d80211_common.h is moved into the=20
net/d80211 directory since only d80211, not the drivers, should be touching=
=20
it.=20

I'm not certain what copyrights should be put at the top of linux/ieee80211=
=2Eh,=20
so I just cobbled together something that seemed reasonable to me. (a lot o=
f=20
the definitions are just copied from net/ieee80211.h now, and most of those=
=20
originated from Jouni, afaik..) Let me know if there's a better way. I also=
=20
added myself since I've been poking at these defines a bit.

Thanks,
=2DMichael Wu

--nextPart4196594.RzlAkqy5Id
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFem8NT3Oqt9AH4aERAjstAKCBd9uno/9KOYvWvmc5LdOtB4DQQwCgsx/X
tjhiBJ6W66F04ZQqRhj9jSQ=
=/dR/
-----END PGP SIGNATURE-----

--nextPart4196594.RzlAkqy5Id--
