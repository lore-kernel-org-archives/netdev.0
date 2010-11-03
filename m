From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 2/2] igb: Don't depend on vlan group for receive size.
Date: Wed, 03 Nov 2010 07:55:59 -0700
Message-ID: <1288796159.3663.1.camel@jtkirshe-MOBL1>
References: <1288464591-31528-1-git-send-email-jesse@nicira.com>
	 <1288464591-31528-2-git-send-email-jesse@nicira.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-wVO4XO01YU9Ecsfao+FD"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45566 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752994Ab0KCO4B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Nov 2010 10:56:01 -0400
In-Reply-To: <1288464591-31528-2-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wVO4XO01YU9Ecsfao+FD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2010-10-30 at 11:49 -0700, Jesse Gross wrote:
> The igb driver currently sets its maximum receive size based on
> whether a vlan group is configured.  However, this causes it to
> completely drop MTU sized vlan packets when there is no vlan
> group, preventing them from showing up in tcpdump, etc.
>=20
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> ---
>  drivers/net/igb/igb_main.c |    5 +----
>  1 files changed, 1 insertions(+), 4 deletions(-)=20

Thanks, I have added this patch to my queue.

--=-wVO4XO01YU9Ecsfao+FD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJM0Xf+AAoJECTsCADr/EWUGJgH/0bb4H1TYui/g3lpp3fAYLQE
cjTLvPLkSQqd24BZ9hU/0HdQ14r+G7Ep/cpVCEDEgMMBQRtVMQCyy3r0wu+cyoam
DRlmA7Dv+PsnhNkbhYfl4A6XpN8jt00CKSEiaOv00p5ykIKaranx97VX9YvVj+2/
/EOxCJigRhh43y1T6oMvttONZAMvCuxuYvw/yuzFaQE2DNzfaCDxEmuW/ETP7IQN
x6gm91lmtXZB5b2K1LvD/eX3nvqd8JkfNQgBX4NAT+WpujdoqvrEa8dl/0SOmR1W
47k3Sp14vFkeaB9SSVNUCgtwZf8tKfe7RhcqLnU2xaxGMqlWJzAc8GQSYBgzoL8=
=7oW7
-----END PGP SIGNATURE-----

--=-wVO4XO01YU9Ecsfao+FD--

