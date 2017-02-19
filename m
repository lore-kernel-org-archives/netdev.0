From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2017-02-19
Date: Sun, 19 Feb 2017 07:39:56 -0800
Message-ID: <20170219153956.GA28473@x1c>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="RnlQjJ0d97Da+TV1"
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:32872 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750868AbdBSPkg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 10:40:36 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's a set of Bluetooth patches for the 4.11 kernel:

 - New USB IDs to the btusb driver
 - Race fix in btmrvl driver
 - Added out-of-band wakeup support to the btusb driver
 - NULL dereference fix to bt_sock_recvmsg

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit b973154a2278c6af0b0efefafb222e0189959659:

  atm: idt77252, use setup_timer and mod_timer (2017-02-15 13:24:53 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 8f91566f99fab8f7a0d2728a1e3defb13675837a:

  btmrvl: fix spelling mistake: "actived" -> "activated" (2017-02-19 00:26:37 +0100)

----------------------------------------------------------------
Christoph Haag (1):
      Bluetooth: btusb: add support for 0bb4:0306

Colin Ian King (4):
      Bluetooth: btmrvl: fix spelling mistake: "caibration" -> "calibration"
      Bluetooth: fix spelling mistake: "advetising" -> "advertising"
      Bluetooth: hci_qca: fix spelling mistake: "Spurrious" -> "Spurious"
      btmrvl: fix spelling mistake: "actived" -> "activated"

Daniel Drake (1):
      Bluetooth: hci_bcm: Add support for BCM2E95 and BCM2E96

Dmitry Tunin (1):
      Bluetooth: Add another AR3012 04ca:3018 device

Ezequiel Garcia (1):
      Bluetooth: Fix NULL pointer dereference in bt_sock_recvmsg

Javier Martinez Canillas (2):
      Bluetooth: btqcomsmd: Fix module autoload
      Bluetooth: btqcomsmd: Allow driver to build if COMPILE_TEST is enabled

Jeffy Chen (3):
      btmrvl: avoid double-disable_irq() race
      btmrvl: set irq_bt to -1 when failed to parse it
      btmrvl: use dt's irqflags for wakeup pin

Rajat Jain (3):
      Bluetooth: btusb: Use an error label for error paths
      Bluetooth: btusb: Add out-of-band wakeup support
      Bluetooth: btusb: Configure Marvell to use one of the pins for oob wakeup

Wen-chien Jesse Sung (2):
      Bluetooth: btusb: Add support for 413c:8143
      Bluetooth: btbcm: Add a delay for module reset

 Documentation/devicetree/bindings/net/btusb.txt    |  43 ++++++
 .../{marvell-bt-sd8xxx.txt => marvell-bt-8xxx.txt} |  46 +++++-
 drivers/bluetooth/Kconfig                          |   2 +-
 drivers/bluetooth/ath3k.c                          |   2 +
 drivers/bluetooth/btbcm.c                          |   3 +
 drivers/bluetooth/btmrvl_main.c                    |   2 +-
 drivers/bluetooth/btmrvl_sdio.c                    |  14 +-
 drivers/bluetooth/btqcomsmd.c                      |   1 +
 drivers/bluetooth/btusb.c                          | 164 +++++++++++++++++++--
 drivers/bluetooth/hci_bcm.c                        |  68 ++++++---
 drivers/bluetooth/hci_qca.c                        |   4 +-
 net/bluetooth/af_bluetooth.c                       |   2 +-
 net/bluetooth/hci_event.c                          |   2 +-
 13 files changed, 300 insertions(+), 53 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/btusb.txt
 rename Documentation/devicetree/bindings/net/{marvell-bt-sd8xxx.txt => marvell-bt-8xxx.txt} (50%)

--RnlQjJ0d97Da+TV1
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJYqbxMAAoJECQj9vv5qNQScpEP/2Q19hkIdwS9FJsWncv9gjNP
yNHcLfyw+bKv0HRmGPDJCJKiV74KNpfGLbQoKQ1ISWHy4fWaDoAI2Ex4Mj5JrRkd
I4pAjg4TtUMkWJOyY2pIBxVbMFfWLQrO4GQTYPCXL2pium+Dv9CAEuSg9zeI7jKK
D6RWqJ0vt3fzHnmMqxJ6FOb+h1ZhIgrQi5nUQy/oPd9+A3JECZnr3T6oni/Dk7U3
duWtsJIYc1+p4kSKLOP6Ut+DG5JmhPhmvwc3WZa5Ykr6DAigUGLHrR2aFhCwpmaX
GoJaUBxWapZeKWD3Ev+6U0+fe9kgrgmZpHTnSdU6uyul8eues0PEsM4c9FB3S4kX
omejsGGEo8HZt+Ozwi8eGCQ/LYnDyfOGSV+IgSYUY8tuTlZ0W09jSmOsxzFWpOHe
Ok9eqATLMiu/ZQ2Djqk4IHGJItZj7DxldMUx2BOBpdkzXyIhT1e6jXmVZFjeM/27
7ELyT2tGD2WAV3lisZl+PH4OOt9oZh36Ax2bSbjt0rEEbTTbEw3VWdIn9CgJFC/K
MdNhwKC77oGFKu8J4cxIFbaBaM0FpzsP7l6xnqK/+W7aZwRRANwl3eusvaxRAUgG
0X77EPoIUYEhRRRAZ3PT+28b6qDDM0KWXDHgRqrfRz/NLMIPFTFFlStR9ym+bnoe
6F+TKvuUzI380ATQN855
=RqEN
-----END PGP SIGNATURE-----

--RnlQjJ0d97Da+TV1--
