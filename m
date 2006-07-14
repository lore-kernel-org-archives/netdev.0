From: Michael Wu <michael.wu@mozilla.com>
Subject: michael_mic in crypto api?
Date: Thu, 13 Jul 2006 23:50:18 -0700
Message-ID: <200607132350.25755.michael.wu@mozilla.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1265467.FmcFjZfsmT";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:59111 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1030340AbWGNGvA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 02:51:00 -0400
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1265467.FmcFjZfsmT
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Is there really a point to having michael_mic in crypto api? The only users=
=20
are 802.11 stacks. I can imagine arc4 being used for other purposes, but=20
michael_mic is very much wireless only. The only advantage of keeping=20
michael_mic in crypto seems to be the testing code.

=2DMichael Wu

--nextPart1265467.FmcFjZfsmT
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEtz6xT3Oqt9AH4aERAlc2AJwP0Tt2JRax1R5MKZNYj5OZRFLaGgCglVE1
4zMAVklVhXMU0ekinvHfR/I=
=8Xf7
-----END PGP SIGNATURE-----

--nextPart1265467.FmcFjZfsmT--
