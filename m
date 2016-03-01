From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2016-03-01
Date: Tue, 1 Mar 2016 09:20:02 +0200
Message-ID: <20160301072002.GA24640@t440s.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jI8keyz6grp/JLjh"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:34224 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508AbcCAHUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 02:20:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's our main set of Bluetooth & 802.15.4 patches for the 4.6 kernel.

 - New Bluetooth HCI driver for Intel/AG6xx controllers
 - New Broadcom ACPI IDs
 - LED trigger support for indicating Bluetooth powered state
 - Various fixes in mac802154, 6lowpan and related drivers
 - New USB IDs for AR3012 Bluetooth controllers

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit a30a9ea6e21b495372aff549f3dfd63198bd1f45:

  rocker: fix rocker_world_port_obj_vlan_add() (2016-02-23 13:12:31 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 34bf1912bfc06bd9200893916078eb0f16480a95:

  Bluetooth: hci_uart: Add diag and address support for Intel/AG6xx (2016-02-29 19:25:22 +0200)

----------------------------------------------------------------
Alexander Aring (9):
      MAINTAINERS: update 802.15.4 entries
      mac802154: fix mac header length check
      at86rf230: fix race on error handling
      at86rf230: fix state change handling on error
      mrf24j40: add writeable missing reg
      6lowpan: iphc: add support for stateful compression
      ieee802154: 6lowpan: fix return of netdev notifier
      6lowpan: iphc: fix stateful multicast compression
      6lowpan: iphc: fix invalid case handling

Andrzej Hajda (1):
      6lowpan: fix error checking code

Anton Protopopov (1):
      Bluetooth: hci_intel: Fix a wrong comparison

Bhumika Goyal (1):
      Bluetooth: ath3k: Fixed a blank line after declaration issue

Dmitry Tunin (3):
      Bluetooth: btusb: Add new AR3012 ID 13d3:3395
      Bluetooth: Add new AR3012 ID 0489:e095
      Bluetooth: btusb: Add a new AR3012 ID 04ca:3014

Heiner Kallweit (2):
      Bluetooth: add LED trigger for indicating HCI is powered up
      Bluetooth: Use managed version of led_trigger_register in LED trigger

J.J. Meijer (1):
      Bluetooth: hci_bcm: Add new ACPI ID for bcm43241

Koen Zandberg (1):
      mac802154: Fixes kernel oops when unloading a radio driver

Loic Poulain (1):
      Bluetooth: hci_uart: Add Intel/AG6xx support

Marcel Holtmann (1):
      Bluetooth: hci_uart: Add diag and address support for Intel/AG6xx

Mika Westerberg (1):
      Bluetooth: hci_bcm: Add BCM2E7C ACPI ID

Petri Gynther (1):
      Bluetooth: btbcm: Fix handling of firmware not found

Wei-Ning Huang (1):
      Bluetooth: hci_core: cancel power off delayed work properly

 MAINTAINERS                        |   9 +-
 drivers/bluetooth/Kconfig          |  11 +
 drivers/bluetooth/Makefile         |   1 +
 drivers/bluetooth/ath3k.c          |   7 +
 drivers/bluetooth/btbcm.c          |   3 +-
 drivers/bluetooth/btusb.c          |   3 +
 drivers/bluetooth/hci_ag6xx.c      | 337 +++++++++++++++++++++++++++++
 drivers/bluetooth/hci_bcm.c        |   2 +
 drivers/bluetooth/hci_intel.c      |   4 +-
 drivers/bluetooth/hci_ldisc.c      |   6 +
 drivers/bluetooth/hci_uart.h       |   8 +-
 drivers/net/ieee802154/at86rf230.c |  25 ++-
 drivers/net/ieee802154/mrf24j40.c  |   1 +
 include/net/6lowpan.h              |  32 +++
 include/net/bluetooth/hci_core.h   |   3 +
 include/net/mac802154.h            |   5 +-
 net/6lowpan/core.c                 |  39 +++-
 net/6lowpan/debugfs.c              | 247 +++++++++++++++++++++
 net/6lowpan/iphc.c                 | 413 +++++++++++++++++++++++++++++++-----
 net/bluetooth/Kconfig              |   9 +
 net/bluetooth/Makefile             |   1 +
 net/bluetooth/hci_core.c           |   7 +
 net/bluetooth/leds.c               |  74 +++++++
 net/bluetooth/leds.h               |  16 ++
 net/ieee802154/6lowpan/core.c      |   7 +-
 net/mac802154/main.c               |   2 +-
 26 files changed, 1192 insertions(+), 80 deletions(-)
 create mode 100644 drivers/bluetooth/hci_ag6xx.c
 create mode 100644 net/bluetooth/leds.c
 create mode 100644 net/bluetooth/leds.h

--jI8keyz6grp/JLjh
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJW1UKiAAoJECQj9vv5qNQSe74P/3wAMpk4fr7s67Awivotxydd
I73z1g0bBnRTfZYEN3YcZhcXBQhDE4RtrjKiOBCU6IqTW+fnhrYIJ8tTZfkvxcLU
OvReKsIfXZF8T18cnGB7z+7ieucpCUl8sWHx7uy1hSvZf5e194cpHY7uRcz6YwWt
j5oKTnU0EG2qzC2VAHd0YcmTkpcGlRCZrzt0ZEmwPwFdGK46316tVlIKtLEycamj
GPYIcOmHN3/Pk6gNpRvCVScbGkjD/Oh54BVyvWHXmHN2CO7RvNSlyanAI3Ttd9Ei
IGWzRxRsp2fyRAMzo63W1Gn8jEJlQZT4Hpf2XYGIvsn+e8/A9saOoX99U/6H2StF
MAKlJgTXYd2qtKrhvWSlrAaaSj1j6CDpsC9MNgkgt0CASKXpj0KB/svx49cfbdnu
eJtZUBU25nf1WM25DVVYxiJxYavaGCIudhgh1AoyTORFDkN3o1SQ91lZIUNN/oky
635qrzWfrLd/JPba94fLlWZNNJ00I1Kpksmnx2EWbxW4OgassGklwhuDf+LI1xSb
2Sx9C1OvhyF+HBWizGm1UPMQplYeJ4tfSIlgxN1ocvOE1a7k0PVCtJdvALza9+FO
UTWAxjDEvxrR2fJMDpE6kukX7oCDHq7VFpbWiTo4EyWg7WHPnRNLIxEJBolNV6qw
sWC9MU4piHHjc6m3+R3C
=tGZP
-----END PGP SIGNATURE-----

--jI8keyz6grp/JLjh--
