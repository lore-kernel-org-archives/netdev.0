From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth-next 2015-08-16
Date: Sun, 16 Aug 2015 09:05:28 +0300
Message-ID: <20150816060528.GA13052@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gKMricLos+KVdGMg"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

Here's what's likely the last bluetooth-next pull request for 4.3:

 - 6lowpan/802.15.4 refactoring, cleanups & fixes
 - Document 6lowpan netdev usage in Documentation/networking/6lowpan.txt
 - Support for UART based QCA Bluetooth controllers
 - Power management support for Broeadcom Bluetooth controllers
 - Change LE connection initiation to always use passive scanning first
 - Support for new Silicon Wave USB ID

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 2cf1b5ce16b61259e3633fb61e6fedaad6e25fc5:

  Merge branch 'mlxsw-fixes' (2015-08-09 22:54:31 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.gi=
t for-upstream

for you to fetch changes up to c0015bf3a34961342a27b021672049e535ab36a1:

  ieee802154: 6lowpan: fix non-lowpan wpan interfaces (2015-08-15 23:28:09 =
+0200)

----------------------------------------------------------------
Alexander Aring (13):
      ieee802154: 6lowpan: remove multiple lowpan per wpan support
      mac802154: fix wpan mac setting while lowpan is there
      mac802154: cfg: remove test and set checks
      mac802154: change frame_retries behaviour
      at86rf230: use STATE_TX_ARET mode only
      ieee802154: add ack request default handling
      ieee802154: 6lowpan: fix error frag handling
      Bluetooth: 6lowpan: change netdev_priv to lowpan_dev
      6lowpan: add generic 6lowpan netdev private data
      6lowpan: move module_init into core functionality
      documentation: networking: add 6lowpan documentation
      ieee802154: 6lowpan: fix packet layer registration
      ieee802154: 6lowpan: fix non-lowpan wpan interfaces

Aniket Nagarnaik (1):
      Bluetooth: btmrvl: release sdio bus after firmware is up

Ben Young Tae Kim (2):
      Bluetooth: btqca: Introduce generic QCA ROME support
      Bluetooth: hciuart: Add support QCA chipset for UART

Ben YoungTae Kim (1):
      Bluetooth: hciuart: Fix to use boolean flag with u32 type

Dan Carpenter (1):
      Bluetooth: Fix breakage in amp_write_rem_assoc_frag()

Frederic Danis (5):
      Bluetooth: hci_bcm: Add PM for BCM devices
      net: rfkill: gpio: Remove BCM2E39 support
      Bluetooth: hci_bcm: Retrieve UART speed from ACPI
      Bluetooth: hci_bcm: Add suspend/resume PM functions
      Bluetooth: hci_bcm: Fix "implicit declaration"

Jakub Pawlowski (6):
      Bluetooth: preparation for new connect procedure
      Bluetooth: add hci_lookup_le_connect
      Bluetooth: add hci_connect_le_scan
      Bluetooth: advertisement handling in new connect procedure
      Bluetooth: timeout handling in new connect procedure
      Bluetooth: Enable new connection establishment procedure.

Lukasz Duda (1):
      6lowpan: Fix extraction of flow label field

Peter Poklop (1):
      Bluetooth: btusb: mark 0c10:0000 devices with BTUSB_SWAVE

Uwe Kleine-K=F6nig (1):
      Bluetooth: hci_bcm: improve use of gpios API

Yong Li (1):
      cc2520: set the default fifo pin value from platform data

 Documentation/networking/6lowpan.txt |  50 ++
 MAINTAINERS                          |   1 +
 drivers/bluetooth/Kconfig            |  17 +
 drivers/bluetooth/Makefile           |   2 +
 drivers/bluetooth/btmrvl_sdio.c      |   4 +-
 drivers/bluetooth/btqca.c            | 392 ++++++++++++++
 drivers/bluetooth/btqca.h            | 135 +++++
 drivers/bluetooth/btusb.c            |   3 +
 drivers/bluetooth/hci_bcm.c          | 310 ++++++++++-
 drivers/bluetooth/hci_ldisc.c        |   6 +
 drivers/bluetooth/hci_qca.c          | 969 +++++++++++++++++++++++++++++++=
+++
 drivers/bluetooth/hci_uart.h         |   8 +-
 drivers/net/ieee802154/at86rf230.c   |  52 +-
 drivers/net/ieee802154/cc2520.c      |   1 +
 include/net/6lowpan.h                |  23 +
 include/net/bluetooth/hci_core.h     |  29 +
 include/net/cfg802154.h              |   8 +
 include/net/nl802154.h               |   4 +
 net/6lowpan/Makefile                 |   2 +-
 net/6lowpan/core.c                   |  40 ++
 net/6lowpan/iphc.c                   |  21 +-
 net/bluetooth/6lowpan.c              |  11 +-
 net/bluetooth/amp.c                  |   2 +-
 net/bluetooth/hci_conn.c             | 235 ++++++++-
 net/bluetooth/hci_core.c             |  33 ++
 net/bluetooth/hci_event.c            |  55 +-
 net/bluetooth/hci_request.c          |   6 +-
 net/bluetooth/l2cap_core.c           |   6 +-
 net/bluetooth/mgmt.c                 |  15 +-
 net/ieee802154/6lowpan/6lowpan_i.h   |  11 +-
 net/ieee802154/6lowpan/core.c        |  79 ++-
 net/ieee802154/6lowpan/rx.c          |  45 +-
 net/ieee802154/6lowpan/tx.c          |   4 +-
 net/ieee802154/nl802154.c            |  33 ++
 net/ieee802154/rdev-ops.h            |  13 +
 net/ieee802154/trace.h               |  19 +
 net/mac802154/cfg.c                  |  27 +-
 net/mac802154/iface.c                |  18 +-
 net/mac802154/main.c                 |   9 +-
 net/rfkill/rfkill-gpio.c             |   1 -
 40 files changed, 2462 insertions(+), 237 deletions(-)
 create mode 100644 Documentation/networking/6lowpan.txt
 create mode 100644 drivers/bluetooth/btqca.c
 create mode 100644 drivers/bluetooth/btqca.h
 create mode 100644 drivers/bluetooth/hci_qca.c
 create mode 100644 net/6lowpan/core.c

--gKMricLos+KVdGMg
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJV0CgoAAoJECQj9vv5qNQSy/oP/RhlqiEmIet8xTgMkTpKfS18
jXCIr9yfNqjcvyWETeuq1VMuyIq5KHRnvW3fDf7E5DqCZEwvwqyQ0eNZq/VgQeb8
oplY4Mz3qiYxWhfn8f0YWXCN48glhljf4LR2n14JX5XPxysUBl4HfS4q0gH8NrFa
bbIVbJ1RId+hpqalDOXmLQ7IxfjonitoMIng3nkTgsR/2NiRbrOznRimug7To7uE
cFDmbzVhNuVxzOJSfKAEp5ij60CAmAn3RMvMiFKcnqVO+hEQ4V8q2u7t8u2Megh2
j+qDE/lVngWLsONP/6I8z6nEUheN/gVg+8BOZbSNiBlh8+746229YsTgyfdmsNNP
Ge923DraA0Cuv8A188rK9jHn1IjZ1SvtFhsMHJltGgw320OObGnHRci554Xljste
Udsor2AlDSLrrRoFzwWBbOoxNtYDYNTCfN8HpPurC/BUcChw2B27hX5V/geC0lum
8+yLkgzs797YfzzUWVOT6+zx7S4vNXI52O9bAdQwJxHmjrWFqKXtqUo8JRVGj8TH
Sh4fb1r8Y8xcVF2ADhzSfwz31DQprgb/QXzSbSWqBSf13Ch9/sKT6Pd9SyrUS6zI
Xe2uic9U1rS4P1O/fnKEiR0Q88M0Q+tht5yzePo7L5IU3kAiGmwE7MIJnwO6QE5n
hFrwnpNiW9DbX8h1T9gi
=a69x
-----END PGP SIGNATURE-----

--gKMricLos+KVdGMg--
