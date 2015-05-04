From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2015-05-04
Date: Mon, 4 May 2015 12:34:36 +0300
Message-ID: <20150504093436.GB9096@t440s.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="St7VIuEGZ6dlpu13"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:35815 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbbEDJep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 05:34:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--St7VIuEGZ6dlpu13
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

Here's the first bluetooth-next pull request for 4.2:

 - Various fixes for at86rf230 driver
 - ieee802154: trace events support for rdev->ops
 - HCI UART driver refactoring
 - New Realtek IDs added to btusb driver
 - Off-by-one fix for rtl8723b in btusb driver
 - Refactoring of btbcm driver for both UART & USB use

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 9dac8835440622c2f84591673969d510ce198c11:

  tcp: update reordering first before detecting loss (2015-04-29 17:10:38 -=
0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.gi=
t for-upstream

for you to fetch changes up to 1add15646672ff4e7fe59bec2afcb5a0c80c5e49:

  ieee802154: trace: fix endian convertion (2015-04-30 18:48:11 +0200)

----------------------------------------------------------------
Alexander Aring (7):
      at86rf230: remove tabs after define
      at86rf230: move cal_timeout to state change
      at86rf230: add TX_ARET_ON for calibration timeout
      at86rf230: remove unnecessary tx state change
      at86rf230: change state change if from trx_off
      at86rf230: add slp_tr support to start tx
      ieee802154: trace: fix endian convertion

Christoffer Holmstedt (1):
      at86rf230: Add macro for TRX STATE MASK

Dan Carpenter (1):
      Bluetooth: btusb: off by one in rtl8723b_parse_firmware()

Daniel Drake (1):
      Bluetooth: btusb: Add Realtek 8723A/8723B/8761A/8821A support

DingXiang (1):
      Bluetooth: bt3c: Delete some unuseful comments

Guido G=FCnther (1):
      ieee802154: Add trace events for rdev->ops

Marcel Holtmann (4):
      Bluetooth: btbcm: Export patchram download as separate function
      Bluetooth: hci_uart: Reorder Atheros specific driver callbacks
      Bluetooth: hci_uart: Add Atheros support for address configuration
      Bluetooth: btusb: Fix two coding style issues

Varka Bhadram (2):
      mac802154: add description to mac802154 APIs
      cfg802154: pass name_assign_type to rdev_add_virtual_intf()

 drivers/bluetooth/bt3c_cs.c        |   3 -
 drivers/bluetooth/btbcm.c          | 148 +++++++------
 drivers/bluetooth/btbcm.h          |   6 +
 drivers/bluetooth/btusb.c          | 403 +++++++++++++++++++++++++++++++++=
++-
 drivers/bluetooth/hci_ath.c        |  98 +++++----
 drivers/net/ieee802154/at86rf230.c | 390 ++++++++++++++++++----------------
 include/net/cfg802154.h            |   2 +
 include/net/mac802154.h            |  94 ++++++++-
 net/ieee802154/Makefile            |   4 +-
 net/ieee802154/nl-phy.c            |   5 +-
 net/ieee802154/nl802154.c          |   2 +-
 net/ieee802154/rdev-ops.h          |  85 ++++++--
 net/ieee802154/trace.c             |   7 +
 net/ieee802154/trace.h             | 247 ++++++++++++++++++++++
 net/mac802154/cfg.c                |   9 +-
 net/mac802154/ieee802154_i.h       |   3 +-
 net/mac802154/iface.c              |   5 +-
 net/mac802154/main.c               |   3 +-
 18 files changed, 1196 insertions(+), 318 deletions(-)
 create mode 100644 net/ieee802154/trace.c
 create mode 100644 net/ieee802154/trace.h

--St7VIuEGZ6dlpu13
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVRz0sAAoJECQj9vv5qNQS2+4QAIdCl4PRidaA3aJGAVe0gsrB
nbcQBx9qCcx7xn8H/Wat3yvS8QKE566tk82mjF6xC7pm/brtJibNJcy0js67b1TR
ku+Hx7yIISGU8NMZ+9EMeKIHHeI0DbxDM+Mdhn9gt6f/tt6h7wNRcFuSYPM9HbCL
NUXob/bCrw6mDLtZ5ScI5blgmFCrRw2E1a1HPnYTMiPKKz4iUzY52cHrot1VcMMK
IYaXEgeOAcKMlE29fMrDr3Bn9eCzgGNWI37LZn+/EdaLPzhKL3SB6RYcnQvZGlpU
UWEvuFjnm6UrpO9vK607x//al0X8hah6c7OT9olPs9RV1/tJnr4zKnFYUVHFoCt3
ln4C71d6YR4+5lddzYfW/vFOnqrVkwtepkWYUPGJFm9sTMRZis5WTSGrhcdB5Gx1
y4JGY4rNA23Zpl84HsKDku8jM3GLs9/K54xCO5xz33Fmv8kb0Abb0Ovmv9TeH85V
B3JKVR+eM1AB23trWo9zDirQWhOXrcMM1tVODX7s3ytk2nO3xxDBVUJsOyJI7oSM
84YkpJU2T1b2H5UVd29eH6N/Ax8yz/YBWxmVHc0TYSPC94M33mXkvNlixl5JXNIA
pAM5YC4iyR9AdKifSShBiyd3i1pIf0aLpvesq+1+MDGwPBflfDEz2zm7p7IPZyeD
vHXKoDGqOJRvKUhBNlK5
=DMrU
-----END PGP SIGNATURE-----

--St7VIuEGZ6dlpu13--
