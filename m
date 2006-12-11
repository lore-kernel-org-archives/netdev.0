From: Michael Wu <flamingice@sourmilk.net>
Subject: d80211-drivers pull request (week-48)
Date: Mon, 11 Dec 2006 01:01:50 -0500
Message-ID: <200612110101.58710.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1816661.qyhYANJtvg";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Drake <dsd@gentoo.org>,
	Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:19317 "EHLO
	annwn13.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762508AbWLKGCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 01:02:16 -0500
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1816661.qyhYANJtvg
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi John,

Please pull
git://git.kernel.org/pub/scm/linux/kernel/git/mwu/d80211-drivers.git week-48
for these patches:

Michael Wu (3):
      zd1211rw-d80211: check IEEE80211_TXCTL_USE_CTS_PROTECT
      zd1211rw-d80211: Use ieee80211_tx_status
      zd1211rw-d80211: Use LED class

 zd_chip.c |    2=20
 zd_chip.h |    5 -
 zd_mac.c  |  200 ++++++++++++++++++++++++++++++++++++++++++---------------=
=2D----
 zd_mac.h  |   25 +++++--
 zd_usb.c  |   27 +++-----
 zd_usb.h  |    2=20
 6 files changed, 169 insertions(+), 92 deletions(-)

This list excludes 8 zd1211rw patch "ports" and 4 patches from the previous=
 pull
request. Note that the LED class patch eliminates the use of workqueues in
zd1211rw-d80211. adm8211 and p54 do not use workqueues either.

Thanks,
=2DMichael Wu

--nextPart1816661.qyhYANJtvg
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFfPRWT3Oqt9AH4aERAgQ5AKCNSJunBdyIUC3WjNnQdAMa3iXk+QCfdk+3
crufnOaWEdLS4ZS2v+UyYq4=
=Moph
-----END PGP SIGNATURE-----

--nextPart1816661.qyhYANJtvg--
