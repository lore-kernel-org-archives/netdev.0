From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2017-08-18
Date: Fri, 18 Aug 2017 19:16:23 +0300
Message-ID: <20170818161623.GA22628@x1c.home>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="5vNYLRcllDrimb99"
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:36608 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751036AbdHRQQ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 12:16:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--5vNYLRcllDrimb99
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's one more bluetooth-next pull request for the 4.14 kernel:

 - Multiple fixes for Broadcom controllers
 - Fixes to the bluecard HCI driver
 - New USB ID for Realtek RTL8723BE controller
 - Fix static analyzer warning with kfree

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 1afec92be0d7b516a79f4c548a81d17460c8ba73:

  Merge branch 'sctp-remove-typedefs-from-structures-part-5' (2017-08-06 21:33:43 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 01d5e44ace8a20fc51e0d530f98acb3c365345a5:

  Bluetooth: hci_bcm: Handle empty packet after firmware loading (2017-08-17 22:51:50 +0300)

----------------------------------------------------------------
Colin Ian King (1):
      Bluetooth: kfree tmp rather than an alias to it

Dmitry Tunin (1):
      Bluetooth: Add support of 13d3:3494 RTL8723BE device

Loic Poulain (2):
      Bluetooth: hci_bcm: Add serdev support
      dt-bindings: net: bluetooth: Add broadcom-bluetooth

Marcel Holtmann (4):
      Bluetooth: btusb: Add workaround for Broadcom devices without product id
      Bluetooth: hci_bcm: Use operation speed of 4Mbps only for ACPI devices
      Bluetooth: btbcm: Consolidate the controller information commands
      Bluetooth: hci_bcm: Handle empty packet after firmware loading

Ondrej Zary (3):
      Bluetooth: bluecard: Always enable LEDs (fix for Anycom CF-300)
      Bluetooth: bluecard: fix LED behavior
      Bluetooth: bluecard: blink LED during continuous activity

Pavel Machek (1):
      Bluetooth: document config options

Sukumar Ghorai (1):
      Bluetooth: btusb: driver to enable the usb-wakeup feature

 .../devicetree/bindings/net/broadcom-bluetooth.txt |  35 +++++++
 drivers/bluetooth/Kconfig                          |   1 +
 drivers/bluetooth/bluecard_cs.c                    |  58 ++++++------
 drivers/bluetooth/btbcm.c                          |  69 ++++++++------
 drivers/bluetooth/btusb.c                          |  24 +++++
 drivers/bluetooth/hci_bcm.c                        | 103 ++++++++++++++++++++-
 net/bluetooth/Kconfig                              |  12 +++
 net/bluetooth/selftest.c                           |   2 +-
 8 files changed, 238 insertions(+), 66 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-bluetooth.txt

--5vNYLRcllDrimb99
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZlxLXAAoJECQj9vv5qNQS0aoP+wf3PTzxiwGsOXSNEA0SoR7c
D9+yr+lL7paFT9oQ+hHwQX0ZKEDeFWGJ9amf1Sgiwoy8ZbjgN6wcaQ+mMruD+iEN
0GxDlUyHydsKaZolhAZxr2H7mpdwP2ID8DDbny3lWaA+2b1Nx9woUUAjjDehI4+8
/dD4rrkUGAC2P/2DA0/jQuEjbiMdosbwNbEC7YxB0xB7/RCbLaErWjp+4/O8YzL3
lMRT8qhhqYpaQVMJ9AVzTGu3cpEibhWhXoMSCgLJX7ZXpFmxSr1bDh6uzGgA9oPD
QPla0x3JiqtCk1dHzU0xwCs7pAijqfqbzvBd3AaTgiI5EnL0FJbRowEDu209oIaQ
PXDEWgT3gvINf6pS/yYlmNOSAF0zP8F6PkYB3SolBv8XP7pzA5NJZRdDK5bBWkYk
j3km1iWo/p+B8QRPL0lip7AD5oIEcFNQFh+R4HutU9/7ag9Qh3G82SpFDL1WtTAP
q/EeFmf0qQYZS5332lr2TPXaQJl4lhoer2bDzZgBl7wtD8cGySnMcZonhlBXTnmE
8buKlkO+xkk7p5u1uBA9how9Z9C0w8FJoUFHA1s1x48qYQtrxDiDFOAV2TGlIL/7
XE6iWncKJb3n9tPVWJHx+fQtCTzAfnAIdBKVixV2pIGGdKt+94/OWcMMoEHluLyH
j8YcguWuP8jbMpebfGr/
=FBYA
-----END PGP SIGNATURE-----

--5vNYLRcllDrimb99--
