From: Johannes Berg <johannes@sipsolutions.net>
Subject: wireless vs. network namespaces
Date: Fri, 14 Sep 2007 11:51:53 +0200
Message-ID: <1189763513.3974.26.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ilTobiyquCFvQ7nIeUqt"
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:50567 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbXINMGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 08:06:02 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ilTobiyquCFvQ7nIeUqt
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Now that the network namespace work is in net-2.6.24, I'm wondering how
wireless will be handling this. Is there any benefit at all to a
wireless device supporting network namespaces?

Should we, for now, set the new NETIF_F_NETNS_LOCAL flag for all
mac80211 devices?

If we do want to support moving, then we'll have to make cfg80211
(preferably, though mac80211 might be easier at first) migrate *all*
virtual interfaces associated with the same wiphy because otherwise
we'll get into trouble when moving one virtual interface and then
somebody in the other namespace changes its operating channel.

johannes

--=-ilTobiyquCFvQ7nIeUqt
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG6lm5/ETPhpq3jKURAju7AKCp1BNqWN0HRepmu4pe7WinB2A3CACfTbiw
tKszf+eEFeKeyTvGpQidgEc=
=V3A8
-----END PGP SIGNATURE-----

--=-ilTobiyquCFvQ7nIeUqt--

