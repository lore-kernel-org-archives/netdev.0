From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2015-03-14
Date: Sat, 14 Mar 2015 20:01:44 +0200
Message-ID: <20150314180144.GA22474@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LZvS9be/3tNcYl/X"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:35638 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbbCNSBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 14:01:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's another set of Bluetooth & ieee802154 patches intended for 4.1:

 - Added support for QCA ROME chipset family in the btusb driver
 - at86rf230 driver fixes & cleanups
 - ieee802154 cleanups
 - Refactoring of Bluetooth mgmt API to allow new users
 - New setting for static Bluetooth address exposed to user space
 - Refactoring of hci_dev flags to remove limit of 32
 - Remove unnecessary fast-connectable setting usage restrictions
 - Fix behavior to be consistent when trying to pair already paired device
 - Service discovery corner-case fixes

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 49b31e576a0a264872aa06dbc1ce6cd0cb9db278:

  filter: refactor common filter attach code into __sk_attach_prog (2015-03-02 14:51:38 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to b6d595e3f74fe0dd9edc0d5bf30cd6e6fe29f023:

  ieee802154: don't export static symbol (2015-03-14 17:11:31 +0100)

----------------------------------------------------------------
Alexander Aring (15):
      at86rf230: add transmit retry support
      at86rf230: cleanup and squash stack variable
      at86rf230: refactor receive handling
      at86rf230: remove multiple dereferencing for irq
      at86rf230: remove multiple dereferencing for ctx
      at86rf230: restore trx len when needed
      Bluetooth: fix sco_exit compile warning
      ieee802154: 6lowpan: fix ARPHRD to ARPHRD_6LOWPAN
      ieee802154: change wpan-phy name to phy
      ieee802154: remove deprecated sysfs entries
      mac802154: correct max sifs size handling
      at86rf230: init xtal_trim with zero
      at86rf230: replace state change sleeps with hrtimer
      at86rf230: add support for calibration timeout
      at86rf230: fix volatile regmap registers

Daniel Drake (1):
      Bluetooth: btusb: Add helper for READ_LOCAL_VERSION command

Jakub Pawlowski (3):
      Bluetooth: Move Service Discovery logic before refactoring
      Bluetooth: Refactor service discovery filter logic
      Bluetooth: fix service discovery behaviour for empty uuids filter

Johan Hedberg (11):
      Bluetooth: Add mgmt HCI channel registration API
      Bluetooth: Convert mgmt to use HCI chan registration API
      Bluetooth: Move all mgmt command quirks to handler table
      Bluetooth: Rename cmd_status() to mgmt_cmd_status()
      Bluetooth: Rename cmd_complete() to mgmt_cmd_complete()
      Bluetooth: Rename pending_cmd to mgmt_pending_cmd
      Bluetooth: Add mgmt_send_event() helper to send to any HCI channel
      Bluetooth: Make Fast Connectable available while powered off
      Bluetooth: Add 'Already Paired' error for Pair Device command
      Bluetooth: Fix missing rcu_read_unlock() in hci_bdaddr_is_paired()
      Bluetooth: Check for matching IRK when looking for paired LE devices

Julia Lawall (1):
      ieee802154: don't export static symbol

Kim, Ben Young Tae (3):
      Bluetooth: btusb: Add setup callback for chip init on USB
      Bluetooth: btusb: Add support for QCA ROME chipset family
      Bluetooth: btusb: Fix incorrect type in qca_device_info

Marcel Holtmann (13):
      Bluetooth: Introduce controller setting information for static address
      Bluetooth: Increment management interface revision
      Bluetooth: Remove two else branches that are not needed
      Bluetooth: Add support connectable advertising setting
      Bluetooth: Introduce hci_dev_test_flag helper macro
      Bluetooth: Introduce hci_dev_set_flag helper macro
      Bluetooth: Introduce hci_dev_clear_flag helper macro
      Bluetooth: Introduce hci_dev_change_flag helper macro
      Bluetooth: Introduce hci_dev_test_and_change_flag helper macro
      Bluetooth: Introduce hci_dev_test_and_clear_flag helper macro
      Bluetooth: Introduce hci_dev_test_and_set_flag helper macro
      Bluetooth: Use DECLARE_BITMAP for hdev->dev_flags field
      Bluetooth: Merge hdev->dbg_flags fields into hdev->dev_flags

 drivers/bluetooth/btusb.c          |  333 +++++-
 drivers/net/ieee802154/at86rf230.c |  226 ++--
 include/linux/ieee802154.h         |    2 +
 include/net/bluetooth/bluetooth.h  |    3 +
 include/net/bluetooth/hci.h        |   22 +-
 include/net/bluetooth/hci_core.h   |   59 +-
 include/net/bluetooth/mgmt.h       |    2 +
 net/bluetooth/af_bluetooth.c       |    9 +
 net/bluetooth/hci_conn.c           |   18 +-
 net/bluetooth/hci_core.c           |  230 +++--
 net/bluetooth/hci_debugfs.c        |   10 +-
 net/bluetooth/hci_event.c          |  127 ++-
 net/bluetooth/hci_request.c        |   34 +-
 net/bluetooth/hci_sock.c           |  108 +-
 net/bluetooth/l2cap_core.c         |   10 +-
 net/bluetooth/mgmt.c               | 1947 ++++++++++++++++++-----------------
 net/bluetooth/sco.c                |    2 +-
 net/bluetooth/smp.c                |   62 +-
 net/ieee802154/6lowpan/core.c      |    2 +-
 net/ieee802154/core.c              |    5 +-
 net/ieee802154/nl-mac.c            |    1 -
 net/ieee802154/sysfs.c             |   49 -
 net/mac802154/util.c               |   13 +-
 23 files changed, 1888 insertions(+), 1386 deletions(-)


--LZvS9be/3tNcYl/X
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVBHeIAAoJECQj9vv5qNQSlWEP/iRuP+FUzcEU1rhDuMFUlibf
HxLg/Duvy9iL1tHmVK97sdMWeS/Aa/FExdET5W/2PE0dMii7quZK8hhWEb0LbaCl
zHa9yon2s0qT8lEkmQgHMEsDoV3R87GsQ03o1MezfCIbXWxsF+8DrTY6S8CNn2B2
9xxhaT5U8WQ9OZK/sFzNvx09w/r/SZ79ZCAwcDRcn+Ax9wXTlQzaPcwOFay8LVj7
sVupzLKXA3Bx7Z54nlkJkkhD582sMvnBKJUayPKa7iXRTgl3/5ulf7l0w7RYAJ0Y
wDwMozI1PcKtrcx7gihzMNkjS1rWi5XIQUCxK6mL10Vbgu/nId76mecQL0i0NS1W
hUxgpZBfoe/2Bgvvb2+t0agPHkqijeIAZzxvcU82CRVUOKZQBLt+jTBkKKYHxchU
BM9XApHPT/+P02ajB5oupXe0zkUWuUcpHnTFFIi2N8FPt3qj8r4IVaV7o2cEX5pp
dQjmBnY9O7XT6Iz5B/B5Vutu5b3HyLj6AlZtoexTuiAU9+fxy5tBn7cQJi8DhO29
ucqJMsBknWuxrzPyvsTGDUwpBLRQ5j0pexhYjdKWOgp/y7m2ecYqXDGLRqNTGV5M
KaT3MAdqzinhr3JEQmHLLJoWPuKdsAN5BpvIROCOw++PUyDsq1RX3iA64ci4hokf
HWh7UDUJwDN5mcv9MU+h
=s+wi
-----END PGP SIGNATURE-----

--LZvS9be/3tNcYl/X--
