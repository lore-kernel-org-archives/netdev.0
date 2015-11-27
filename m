From: William Dauchy <william@gandi.net>
Subject: dynamically set number of queues for 82598 devices in -stable
Date: Fri, 27 Nov 2015 11:05:57 +0100
Message-ID: <20151127100557.GB21147@gandi.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="WxezjuMNsgvRf6mf"
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	Emil Tantilov <emil.s.tantilov@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:41487 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752958AbbK0KGA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Nov 2015 05:06:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--WxezjuMNsgvRf6mf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello Jeff,

I faced the problem described in commit 7e3f5c8:
ixgbe: fix bounds checking in ixgbe_setup_tc for 82598

This patch resolves an issue where users were not able to dynamically
set number of queues for 82598 via ethtool -L


I backported it for my v4.1.x build but I was wondering if this could be
a candidate for a backport in stable tree at least for v4.1.x.

Thanks,
--=20
William

--WxezjuMNsgvRf6mf
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlZYKwUACgkQ1I6eqOUidQHH1QCZAdC4rOgfJL5GGHlX8c4KohbI
WTQAoKG90yQXV9J6cch1dZfX4f+vq5a8
=lGAZ
-----END PGP SIGNATURE-----

--WxezjuMNsgvRf6mf--
