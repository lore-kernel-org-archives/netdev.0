From: William Dauchy <william@gandi.net>
Subject: loop on reset adapter with ixgbe
Date: Wed, 20 Nov 2013 19:25:24 +0100
Message-ID: <20131120182524.GC16953@gandi.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="JgQwtEuHJzHdouWu"
Cc: Jacob Keller <jacob.e.keller@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Leonardo Potenza <leonardo.potenza@intel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:35507 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752998Ab3KTSdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Nov 2013 13:33:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--JgQwtEuHJzHdouWu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On some machines with a network card named
"Intel Corporation 82599EB 10-Gigabit SFI/SFP+"

At boot time, I'm getting an infinite loop showing these messages:

ixgbe 0000:03:00.0 eth0: initiating reset to clear Tx work after link loss
ixgbe 0000:03:00.0 eth0: Reset adapter
ixgbe 0000:03:00.0 eth0: detected SFP+: 3

ethtool info:
driver: ixgbe
version: 3.8.21-k
firmware-version: 0x00000000

I'm using the last linux stable branch v3.10.x.

I need to unplug/plug the network/cable (a twinax cable) several times to
stabilize the situation and get some network.
I was wondering if I should consider this as a driver/firmware bug or if I
should look for a physical issue (I changed the physical cable several time=
s).
Or do you need some more info to help understand this issue?

Best regards,
--=20
William

--JgQwtEuHJzHdouWu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlKM/pQACgkQ1I6eqOUidQHLDgCeIMPxRSv0Dsiy9Kti6d0+jb2R
bxsAmwXgfh5iHUDbUp+remN4Iwri0Hdq
=hlbJ
-----END PGP SIGNATURE-----

--JgQwtEuHJzHdouWu--
