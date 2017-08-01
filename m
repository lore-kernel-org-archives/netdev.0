From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2017-08-01
Date: Tue, 1 Aug 2017 12:41:56 +0300
Message-ID: <20170801094156.GA22557@x1c.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="wac7ysb48OaltWcw"
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:33533 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751012AbdHAJmF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 05:42:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's our first batch of Bluetooth patches for the 4.14 kernel:

 - Several new USB IDs for the btusb driver
 - Memory leak fix in btusb driver
 - Cleanups & fixes to hci_nokia, hci_serdev and hci_bcm drivers
 - Fixed cleanup path in mrf24j40 (802.15.4) driver probe function
 - A few other smaller cleanups & fixes to drivers

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 04d8980b4a9ca178be1c703467f2ed4ac0800e90:

  cxgb4: Update register ranges of T4/T5/T6 adapters (2017-07-19 22:27:03 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to d829b9e230f4138fb6194e854e1bb46f737f1c3d:

  Bluetooth: btusb: add ID for LiteOn 04ca:3016 (2017-08-01 08:28:31 +0300)

----------------------------------------------------------------
Brian Norris (1):
      Bluetooth: btusb: add ID for LiteOn 04ca:3016

Christophe JAILLET (1):
      mrf24j40: Fix en error handling path in 'mrf24j40_probe()'

Dan Carpenter (1):
      Bluetooth: btrtl: Fix a error code in rtl_load_config()

Derek Robson (1):
      Bluetooth: Style fix - align block comments

Dmitry Tunin (1):
      Bluetooth: btusb: Add support of all Foxconn (105b) Broadcom devices

Gustavo A. R. Silva (1):
      Bluetooth: btwilink: remove unnecessary static in bt_ti_probe()

Ian Molton (5):
      Bluetooth: hci_nokia: prevent crash on module removal
      Bluetooth: hci_nokia: remove duplicate call to pm_runtime_disable()
      Bluetooth: hci_serdev: Introduce hci_uart_unregister_device()
      Bluetooth: hci_nokia: Use new hci_uart_unregister_device() function
      Bluetooth: hci_ll: Use new hci_uart_unregister_device() function

Jeffy Chen (1):
      Bluetooth: btusb: Fix memory leak in play_deferred

Joan Jani (1):
      Bluetooth: btqca: Fixed a coding style error

Leif Liddy (1):
      Bluetooth: btusb: fix QCA Rome suspend/resume

Loic Poulain (2):
      Bluetooth: hci_bcm: Make bcm_request_irq fail if no IRQ resource
      Bluetooth: hci_uart: Fix uninitialized alignment value

Marcel Holtmann (1):
      Bluetooth: hci_nokia: select BT_BCM for btbcm_set_bdaddr()

 drivers/bluetooth/Kconfig         |  1 +
 drivers/bluetooth/ath3k.c         |  3 ++-
 drivers/bluetooth/bt3c_cs.c       |  8 ++++---
 drivers/bluetooth/btmrvl_sdio.c   |  6 ++++--
 drivers/bluetooth/btqca.c         |  2 +-
 drivers/bluetooth/btrtl.c         |  2 ++
 drivers/bluetooth/btsdio.c        |  3 ++-
 drivers/bluetooth/btuart_cs.c     |  8 ++++---
 drivers/bluetooth/btusb.c         | 44 ++++++++++++++++++++++++++++++++-------
 drivers/bluetooth/btwilink.c      |  8 +++----
 drivers/bluetooth/hci_bcm.c       | 30 +++++++++++++-------------
 drivers/bluetooth/hci_h4.c        |  2 +-
 drivers/bluetooth/hci_ldisc.c     |  3 ++-
 drivers/bluetooth/hci_ll.c        | 11 +++-------
 drivers/bluetooth/hci_nokia.c     | 10 +--------
 drivers/bluetooth/hci_serdev.c    | 13 ++++++++++++
 drivers/bluetooth/hci_uart.h      |  1 +
 drivers/net/ieee802154/mrf24j40.c |  3 ++-
 18 files changed, 101 insertions(+), 57 deletions(-)

--wac7ysb48OaltWcw
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZgEzkAAoJECQj9vv5qNQSZygQAJxl84cjg2Ly6YL1zVpgghb6
UFCp3BXW9HiTzCw71WhhvS67VYDNuS9JYB0nBvr+1GABDFu7OKWmdHrdCkJWNshO
Abc9fg7VFICt95uKG4R+DfVYhviSZiF2SZ9Rua8oQWiTVKQV5OuDt8gudgqWybhN
eVsQRrV0+g4UeKfGrCOMFQXcFVbUdFIjwG45oJX2O91X3Drm3w6+x1njOBa0MB6B
pyswGJb5H2lXOOxjLMA+JwUstF/af8uYE9b0GZTASXuoo0VMn65pfckl2xLD9pVR
ajYwI5U6F928Tyqe8zuXfWOlji7g+X5tTuzcGQK7Z24b8pzA5ptfWxYCFNrFqUuA
QMo5GGLkDFD8hsL06sTuYOqDPme1Qg79pKyAK7RdLCIiw9673u/bzvh43Hi6un1N
JChNxx13hll4ViocNsk9Op7BGQkf1E56or5O35UxTED/ttAum5JJ/8Krv4twnwwR
VfZWT2kyaXtQ1WV2uWGq1QmP7DXZ6zQmqas/5rDV/utIqgHvI24+h2/dLuOPbzDm
tt7IdfpVROK1cIX/uIhLUWyvrqvRm2Fln5gZ/i4jY6pemhkPsguOSlRmJOdRYa+m
hqmdh1tADmuplTJ62/3WNJs+SGL0iuGf7HvrFZ4dIVXXuXDHvl0FCBngJ0qYArZq
ubJabOt99NNu2tLMwpEe
=8+u3
-----END PGP SIGNATURE-----

--wac7ysb48OaltWcw--
