From: Johannes Berg <johannes@sipsolutions.net>
Subject: set_multicast_list vs. set_rx_mode
Date: Wed, 15 Aug 2007 14:33:28 +0200
Message-ID: <1187181208.3998.44.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-fXs1SAJhFWcOYlpeAwIb"
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:37951 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753976AbXHOMau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 08:30:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-fXs1SAJhFWcOYlpeAwIb
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hey,

Is it intentional that in the case where set_rx_mode is assigned, you
still need to assign set_multicast_list even if it won't ever be called
as a flag for SIOCADDMULTI?

I was thinking of converting the wireless code to use set_rx_mode and
assign set_multicast_list only if the underlying hardware supports
multicast filtering, and it seems that is well-supported, but it does
seem a bit weird that set_multicast_list degrades to a flag.

johannes

--=-fXs1SAJhFWcOYlpeAwIb
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGwvKY/ETPhpq3jKURAl1IAJ9zZxUFuuzVmnOVdIPTugiQ84bYDQCfWSxM
JiAZVaS4DZP30YRZ5897JjE=
=Cg6N
-----END PGP SIGNATURE-----

--=-fXs1SAJhFWcOYlpeAwIb--

