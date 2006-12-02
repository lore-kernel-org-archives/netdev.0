From: Michael Wu <flamingice@sourmilk.net>
Subject: d80211-drivers pull request
Date: Sat, 2 Dec 2006 14:44:50 -0500
Message-ID: <200612021445.08620.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4209684.Whxk0gnac0";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Drake <dsd@gentoo.org>,
	Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:56230 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1758509AbWLBTpb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 14:45:31 -0500
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4209684.Whxk0gnac0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi John,

Please pull
git://git.kernel.org/pub/scm/linux/kernel/git/mwu/d80211-drivers.git up
for these patches:

Michael Wu (4):
      zd1211-d80211: Copy zd1211 driver to d80211 directory
      zd1211-d80211: Hook up Kconfig and Makefiles
      zd1211-d80211: Port zd1211 to Devicescape stack
      p54: Don't send startup packet again on next ifup (USB)

 Kconfig                  |    1
 Makefile                 |    1
 p54/prism54usb.c         |   26
 zd1211rw/Kconfig         |   19
 zd1211rw/Makefile        |   11
 zd1211rw/zd_chip.c       | 1655=20
+++++++++++++++++++++++++++++++++++++++++++++++
 zd1211rw/zd_chip.h       |  845 +++++++++++++++++++++++
 zd1211rw/zd_def.h        |   54 +
 zd1211rw/zd_ieee80211.h  |   68 +
 zd1211rw/zd_mac.c        |  638 ++++++++++++++++++
 zd1211rw/zd_mac.h        |  247 +++++++
 zd1211rw/zd_rf.c         |  156 ++++
 zd1211rw/zd_rf.h         |   83 ++
 zd1211rw/zd_rf_al2230.c  |  373 ++++++++++
 zd1211rw/zd_rf_al7230b.c |  274 +++++++
 zd1211rw/zd_rf_rf2959.c  |  279 +++++++
 zd1211rw/zd_types.h      |   71 ++
 zd1211rw/zd_usb.c        | 1423 ++++++++++++++++++++++++++++++++++++++++
 zd1211rw/zd_usb.h        |  243 ++++++
 zd1211rw/zd_util.c       |   82 ++
 zd1211rw/zd_util.h       |   29
 21 files changed, 6574 insertions(+), 4 deletions(-)

Thanks,
=2DMichael Wu

--nextPart4209684.Whxk0gnac0
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFcdfET3Oqt9AH4aERApb9AJ9WkmLtzQrtvl5OfiGxHR8ydMJx6ACdEfjr
MEp4oERJvRnXLD84W/mcDbk=
=ceJW
-----END PGP SIGNATURE-----

--nextPart4209684.Whxk0gnac0--
