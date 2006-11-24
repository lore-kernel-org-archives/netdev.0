From: Michael Wu <flamingice@sourmilk.net>
Subject: d80211-drivers pull request
Date: Fri, 24 Nov 2006 14:34:05 -0500
Message-ID: <200611241434.27149.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1720138.YMkGTz1oqM";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, developers@islsm.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:62907 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S935028AbWKXTfj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Nov 2006 14:35:39 -0500
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1720138.YMkGTz1oqM
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

Please pull
git://git.kernel.org/pub/scm/linux/kernel/git/mwu/d80211-drivers.git master
for these patches:

Michael Wu:
      p54: Set dummy maxssi to prevent a divide by zero.
      p54: Add PCI driver
      p54: Add license boilerplate
      p54: Move eeprom readback packet filling code to common
      Update MAINTAINERS entries for wireless drivers
      adm8211: Reduce delays
      adm8211: Convert to new API
      p54: Convert to new API

 MAINTAINERS                                     |   20
 drivers/net/wireless/d80211/adm8211/adm8211.c   |  336 +++++------
 drivers/net/wireless/d80211/adm8211/adm8211.h   |    1
 drivers/net/wireless/d80211/p54/Kconfig         |    3
 drivers/net/wireless/d80211/p54/Makefile        |    1
 drivers/net/wireless/d80211/p54/prism54.h       |   41 -
 drivers/net/wireless/d80211/p54/prism54common.c |  239 +++++---
 drivers/net/wireless/d80211/p54/prism54common.h |   19
 drivers/net/wireless/d80211/p54/prism54magic.h  |   33 +
 drivers/net/wireless/d80211/p54/prism54pci.c    |  692=20
++++++++++++++++++++++++
 drivers/net/wireless/d80211/p54/prism54pci.h    |   99 +++
 drivers/net/wireless/d80211/p54/prism54usb.c    |   94 +--
 drivers/net/wireless/d80211/p54/prism54usb.h    |   20
 13 files changed, 1278 insertions(+), 320 deletions(-)

Thanks,
=2DMichael Wu

--nextPart1720138.YMkGTz1oqM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFZ0lCT3Oqt9AH4aERAkA+AKCE2N6oKQDamkBmbAYT8m3MAf5EegCgtwQi
uPnq/JjwGFkXOcUPNKtjuv0=
=fWLO
-----END PGP SIGNATURE-----

--nextPart1720138.YMkGTz1oqM--
