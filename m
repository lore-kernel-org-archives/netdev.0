From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2016-04-26
Date: Tue, 26 Apr 2016 12:54:35 +0300
Message-ID: <20160426095435.GA8699@t440s>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="huq684BweRXVnRxX"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:34025 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbcDZJyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 05:54:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's another set of Bluetooth & 802.15.4 patches for the 4.7 kernel:

 - Cleanups & refactoring of ieee802154 & 6lowpan code
 - Security related additions to ieee802154 and mrf24j40 driver
 - Memory corruption fix to Bluetooth 6lowpan code
 - Race condition fix in vhci driver
 - Enhancements to the atusb 802.15.4 driver

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit b30d27f5bba2c65fb571ad7448b18dfee2fd63ae:

  Merge branch 'mediatek-stress-test-fixes' (2016-04-12 22:41:33 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 55441070ca1cbd47ce1ad2959bbf4b47aed9b83b:

  Bluetooth: 6lowpan: Fix memory corruption of ipv6 destination address (2016-04-26 01:08:25 +0200)

----------------------------------------------------------------
Alexander Aring (12):
      ieee802154: cleanups for ieee802154.h
      ieee802154: add short address helpers
      nl802154: avoid address change while running lowpan
      ieee802154: 6lowpan: fix short addr hash
      6lowpan: change naming for lowpan private data
      6lowpan: move lowpan_802154_dev to 6lowpan
      6lowpan: iphc: rename add lowpan prefix
      6lowpan: iphc: remove unnecessary zero data
      6lowpan: move eui64 uncompress function
      6lowpan: add lowpan_is_ll function
      6lowpan: move mac802154 header
      at86rf230: increase sleep to off timings

Alexandre Macabies (3):
      ieee802154: add security bit check function
      mrf24j40: fix security-enabled processing on inbound frames
      mrf24j40: apply the security-enabled bit on secured outbound frames

Dan Carpenter (1):
      Bluetooth: ath3k: Silence uninitialized variable warning

Glenn Ruben Bakke (1):
      Bluetooth: 6lowpan: Fix memory corruption of ipv6 destination address

Johan Hedberg (1):
      Bluetooth: Add defines for SPI and I2C

Stefan Schmidt (4):
      ieee802154: atusb: implement .set_csma_params ops callback
      ieee802154: atusb: implement .set_cca_ed_level ops callback
      ieee802154: atusb: implement .set_cca_mode ops callback
      ieee802154: atusb: update my copyright years for this driver

Takashi Iwai (1):
      Bluetooth: vhci: Fix race at creating hci device

 drivers/bluetooth/ath3k.c          |   6 +-
 drivers/bluetooth/hci_vhci.c       |  23 ++++++--
 drivers/net/ieee802154/at86rf230.c |   6 +-
 drivers/net/ieee802154/atusb.c     |  91 ++++++++++++++++++++++++++++-
 drivers/net/ieee802154/mrf24j40.c  |  14 ++++-
 include/linux/ieee802154.h         |  45 ++++++++++++++-
 include/net/6lowpan.h              |  37 +++++++++++-
 include/net/bluetooth/hci.h        |   2 +
 include/net/mac802154.h            |  10 ++++
 net/6lowpan/6lowpan_i.h            |   9 +++
 net/6lowpan/core.c                 |   8 +--
 net/6lowpan/debugfs.c              |  22 +++----
 net/6lowpan/iphc.c                 | 111 ++++++++++++++++--------------------
 net/6lowpan/nhc_udp.c              |   2 +-
 net/bluetooth/6lowpan.c            |  93 +++++++++++++++---------------
 net/ieee802154/6lowpan/6lowpan_i.h |  14 +----
 net/ieee802154/6lowpan/core.c      |   6 +-
 net/ieee802154/6lowpan/tx.c        |  14 ++---
 net/ieee802154/nl802154.c          |  10 ++++
 19 files changed, 356 insertions(+), 167 deletions(-)

--huq684BweRXVnRxX
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXHzrbAAoJECQj9vv5qNQSohQQAK6c3JB6lteVNemFa4rMlw7Y
PZSO8fxb/OHkFC9f64Y2/iFt049sSgxQvdQdhVpNknrSOsWfEXv+M9/71AWk/Rz1
ljQ1+GGSYV9ZAon25RGtt+EnaDdF3zG0VEqjSaQ6bKMPShHcMo7immfNrpdEdhuX
rkW33c3aOdgbBY38chHtj2NcaO8WVbeBHZdTHViRPFHkpMscNlZRx5A3xtrTE1jp
qm+pDWyFxP4MudFN7Km3PXhrxQtr9ujeFzsbI7UYE1kiXMJWilmvGNUn1ahmQ5ze
MCKtto2Kw0+8/JlC4lS/Pf3VY1cP6dEDli+eOZCqGyKr+A1/SkJr8cNi7fsMur4M
CGLwku3YEw5uGfcMZzyGzbvTRHIokfaiifnqjisVopvKV4Lb2JUx8SVaExmcOLAl
YRQsxL24kTPDfBDiy+Y2QmBZVENpWrfjlUOqoEtnq8cgmYcCWTjeSr15gXtKPBcD
JN4MqvCuuOx2sXJpPBrBe0YBEfrybR7thNbthKVR1thCZppJdvMgwlbw/4Auz5zd
4Klpcl4ALbkSVa/wHYywol1w0jkQH25onxmjr3G+S96AbrZUX/2P9HPGmfIcshVW
J5BFj5wuMrFa+jzENoJXlhkbvz8D5fMXDAx4C5XyTwqAHlNiCxMu5XQAjb4kEKdV
co1o/oGEYcG82OwR/8+V
=f9Gs
-----END PGP SIGNATURE-----

--huq684BweRXVnRxX--
