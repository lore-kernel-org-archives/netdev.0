From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2016-04-12
Date: Tue, 12 Apr 2016 11:08:15 +0300
Message-ID: <20160412080815.GA17516@t440s>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Q68bSM7Ycu6FN28Q"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:34548 "EHLO
	mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932191AbcDLIIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 04:08:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's a set of Bluetooth & 802.15.4 patches intended for the 4.7 kernel:

 - Fix for race condition in vhci driver
 - Memory leak fix for ieee802154/adf7242 driver
 - Improvements to deal with single-mode (LE-only) Bluetooth controllers
 - Fix for allowing the BT_SECURITY_FIPS security level
 - New BCM2E71 ACPI ID
 - NULL pointer dereference fix fox hci_ldisc driver

Let me know if there are any issues pulling. Thanks.

Johan

----
The following changes since commit 9ef280c6c28f0c01aa9d909263ad47c796713a8e:

  irda: sh_irda: remove driver (2016-04-04 16:24:13 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 8805eea2494a2837983bc4aaaf6842c89666ec25:

  Bluetooth: hci_bcsp: fix code style (2016-04-08 23:01:36 +0200)

----------------------------------------------------------------
Alexander Aring (1):
      6lowpan: iphc: fix handling of link-local compression

Jiri Slaby (2):
      Bluetooth: vhci: fix open_timeout vs. hdev race
      Bluetooth: vhci: purge unhandled skbs

Johan Hedberg (2):
      Bluetooth: Fix setting NO_BREDR advertising flag
      Bluetooth: Ignore unknown advertising packet types

Loic Poulain (2):
      Bluetooth: hci_bcm: Add BCM2E71 ACPI ID
      Bluetooth: hci_ldisc: Fix null pointer derefence in case of early data

Maxim Zhukov (1):
      Bluetooth: hci_bcsp: fix code style

Patrik Flykt (1):
      Bluetooth: Allow setting BT_SECURITY_FIPS with setsockopt

Sudip Mukherjee (1):
      ieee802154/adf7242: fix memory leak of firmware

 drivers/bluetooth/hci_bcm.c      |  1 +
 drivers/bluetooth/hci_bcsp.c     | 57 +++++++++++++++++++++++++++++++--------------------------
 drivers/bluetooth/hci_ldisc.c    | 11 +++++++----
 drivers/bluetooth/hci_uart.h     |  1 +
 drivers/bluetooth/hci_vhci.c     |  9 ++++++---
 drivers/net/ieee802154/adf7242.c |  2 ++
 net/6lowpan/iphc.c               | 11 +++++++++--
 net/bluetooth/hci_event.c        | 13 +++++++++++++
 net/bluetooth/hci_request.c      |  6 +++---
 net/bluetooth/l2cap_sock.c       |  2 +-
 10 files changed, 74 insertions(+), 39 deletions(-)


--Q68bSM7Ycu6FN28Q
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXDKzvAAoJECQj9vv5qNQS1P8QAK+6mw7f5n9M6zNchFYuCsA2
KzFc2jmGUbIsw31ZKCyps0eQpUe01RWuM67wnvjBdRaOjVI+82l3QKdHU8A7xmo8
RIkEoKpMIXwpN6R5W9DOvT/LVEvttMmMl4nHdpUWWKyDXLII4DSpdDmw+CSqn7gk
7zvypSHVh8JSKkbySciTS82CqeveaU93peY6OovnzBU+nIQn3ru+mrZ3mx9H45t0
hu/gfECJTQmTtG31iWH6KH+8NSTcx5BILiXSJl4Rsk07+l2xRQDKQdylUylXIi2o
n7lpoaxVI5hVP1SQUr47t56nZZwIOLEWc2qE0MLQVs2PJ8kMSC43ZETkb9yFDPGm
G3bp3RmCXoyYrQApVx3TMBsViJjJw0JbqaK784M+BqQNgOu0e2w1dEZ52rRiyirs
Y0Vy7dQKtYGefb16//g78af9LaY4Tv+DqSfE7YkccVg/OZAVkVQ0FpJhF3WUIk5Z
9mO8nlgus1wTHKki9IHVVxU+b3vUQxx4XQUOxj2oNb7xV/nfMTB0AwD9PvrqZXAw
NyOoCBBUfQok3VUfEEjRrBTKolemCMt0zvlDWYChouBJpfsWGhZ4bD6+pRFJREZj
u4g2kdZAvlQWzPKk0IZM6d44dZtIZB6tWhu+B+VF8syxTNhwed7oIHDSIzfRpjCA
2DHcZW/Qp7tKF/Crvey0
=Lq87
-----END PGP SIGNATURE-----

--Q68bSM7Ycu6FN28Q--
