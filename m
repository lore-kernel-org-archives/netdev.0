From: William Dauchy <william@gandi.net>
Subject: dynamically set number of queues for 82598 devices
Date: Thu, 29 Oct 2015 16:26:45 +0100
Message-ID: <20151029152645.GD7657@gandi.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="M38YqGLZlgb6RLPS"
Cc: netdev@vger.kernel.org, Tal Abudi <talabudi@gmail.com>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:49225 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752670AbbJ2P0s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 11:26:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--M38YqGLZlgb6RLPS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello David,

I faced the problem described in commit 7e3f5c8:
ixgbe: fix bounds checking in ixgbe_setup_tc for 82598

This patch resolves an issue where users were not able to dynamically
set number of queues for 82598 via ethtool -L


I backported it for my v4.1.x build but I was wondering if this could be
a candidate for a backport in stable tree at least for v4.1.x.

Thanks,
--=20
William

--M38YqGLZlgb6RLPS
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlYyOrUACgkQ1I6eqOUidQEO9wCgtY1Fej4Vi9Iolx0iIv1vteVb
CRIAnRt5q/lYQxKfSnG2hyIODKm+t9qc
=lPJ3
-----END PGP SIGNATURE-----

--M38YqGLZlgb6RLPS--
