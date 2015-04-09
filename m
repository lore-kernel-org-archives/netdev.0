From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth-next 2015-04-09
Date: Thu, 9 Apr 2015 22:58:50 +0300
Message-ID: <20150409195850.GA23404@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pWyiEgJYm5f9v55/"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--pWyiEgJYm5f9v55/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

We've had enough new patches during the past week (especially from
Marcel) that it'd be good to still get these queued for 4.1.

The majority of the changes are from Marcel with lots of cleanup &
refactoring patches for the HCI UART driver. Marcel also split out some
Broadcom & Intel vendor specific functionality into two new btintel &
btbcm modules.

In addition to the HCI driver changes there's the completion of our
local OOB data interface for pairing, added support for requesting
remote LE features when connecting, as well as a couple of minor fixes
for mac802154.

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 7abccdba25be45630eede85053496f1f48d36ec8:

  Merge branch 'for-upstream' of git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next (2015-04-07 11:47:52 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 23310f6f3a8f30f4b6794e941763da4708f7471a:

  mac802154: fix transmission power datatype (2015-04-09 19:56:15 +0200)

----------------------------------------------------------------
Johan Hedberg (2):
      Bluetooth: Update SSP OOB data EIR definitions
      Bluetooth: Add local SSP OOB data to OOB ext data mgmt command

Marcel Holtmann (34):
      Bluetooth: hci_uart: Add support for vendor detection flag
      Bluetooth: hci_uart: Add support Intel address configuration
      Bluetooth: hci_uart: Add support Broadcom address configuration
      Bluetooth: hci_uart: Remove unneeded cast of tty->disc_data
      Bluetooth: hci_uart: Fix indentation issues for multi-line functions
      Bluetooth: hci_uart: Remove unused h4->rx_skb field
      Bluetooth: hci_uart: Remove unused h4->rx_state and h4->rx_count field
      Bluetooth: Make data pointer of hci_recv_stream_fragment const
      Bluetooth: hci_uart: Use const data pointer for received data
      Bluetooth: hci_uart: Introduce h4_recv_buf helper function
      Bluetooth: hci_uart: Use h4_recv_buf helper for H:4 protocol
      Bluetooth: hci_uart: Use h4_recv_buf helper for Atheros AR300x
      Bluetooth: Remove hci_recv_stream_fragment function
      Bluetooth: hci_uart: Make struct hci_uart_proto always const
      Bluetooth: hci_uart: Add name information to hci_uart_proto struct
      Bluetooth: hci_uart: Remove the manual protocol init message
      Bluetooth: hci_uart: Update version number driver
      Bluetooth: btbcm: Introduce generic Broadcom Bluetooth support
      Bluetooth: btusb: Use generic functionality by Broadcom module
      Bluetooth: hci_uart: Use generic functionality from Broadcom module
      Bluetooth: btbcm: Add support for Broadcom controller setup
      Bluetooth: btusb: Add option for Broadcom protocol support
      Bluetooth: btusb: Move Broadcom quirk setting into support module
      Bluetooth: btusb: Update version number of the module
      Bluetooth: hci_uart: Move setup callback into different location
      Bluetooth: hci_uart: Add protocol support for Broadcom UART devices
      Bluetooth: btbcm: Add firmware table for UART based devices
      Bluetooth: hci_uart: Provide generic H:4 receive framework
      Bluetooth: btintel: Introduce generic Intel Bluetooth support
      Bluetooth: btusb: Use generic Intel support for address support
      Bluetooth: btusb: Move Intel command structs into its own header
      Bluetooth: hci_uart: Use generic Intel support for address setting
      Bluetooth: Read LE remote features during connection establishment
      Bluetooth: btusb: Use proper data structures for Intel vendor events

Varka Bhadram (2):
      mac802154: fix typo for device
      mac802154: fix transmission power datatype

 drivers/bluetooth/Kconfig          |  41 ++++
 drivers/bluetooth/Makefile         |   4 +
 drivers/bluetooth/btbcm.c          | 387 +++++++++++++++++++++++++++++
 drivers/bluetooth/btbcm.h          |  54 +++++
 drivers/bluetooth/btintel.c        | 101 ++++++++
 drivers/bluetooth/btintel.h        |  89 +++++++
 drivers/bluetooth/btusb.c          | 469 ++++++------------------------------
 drivers/bluetooth/hci_ath.c        |  49 ++--
 drivers/bluetooth/hci_bcm.c        | 153 ++++++++++++
 drivers/bluetooth/hci_bcsp.c       |  18 +-
 drivers/bluetooth/hci_h4.c         | 132 ++++++++--
 drivers/bluetooth/hci_h5.c         |  16 +-
 drivers/bluetooth/hci_intel.c      |  31 +++
 drivers/bluetooth/hci_ldisc.c      |  86 +++++--
 drivers/bluetooth/hci_ll.c         |  16 +-
 drivers/bluetooth/hci_uart.h       |  55 ++++-
 drivers/net/ieee802154/at86rf230.c |   2 +-
 include/net/bluetooth/hci.h        |  19 +-
 include/net/bluetooth/hci_core.h   |   3 -
 include/net/mac802154.h            |   4 +-
 net/bluetooth/hci_core.c           | 148 +-----------
 net/bluetooth/hci_event.c          | 107 +++++++-
 net/bluetooth/mgmt.c               | 154 +++++++++++-
 23 files changed, 1481 insertions(+), 657 deletions(-)
 create mode 100644 drivers/bluetooth/btbcm.c
 create mode 100644 drivers/bluetooth/btbcm.h
 create mode 100644 drivers/bluetooth/btintel.c
 create mode 100644 drivers/bluetooth/btintel.h
 create mode 100644 drivers/bluetooth/hci_bcm.c
 create mode 100644 drivers/bluetooth/hci_intel.c


--pWyiEgJYm5f9v55/
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVJtn6AAoJECQj9vv5qNQSuxYQAJnmigi6anuyeYKhO8jbIMS7
+uT1HgSRYMS2Ueh/gUduSqha2P+q9fEdrB4C4IJg2vBP0JM2ikZMXJkbLzKJLOxb
XLBoudge9xh6XqDU1Z4ALob65T4FvtzlszLx8BbUGssRtCtu4/tOzy0WE5Q0XkY2
cjbFVKp2vECoKpJnHeD4jhdZd8kcaDDvZBokpKJkuxj14IVOM2doH3Lemgwr7i01
Jf+pqrKtoHt4RvfxOws9xqyUOGhKwOBX0OO2/0EhEuHVwJ4864I+SWKCWULs9w/o
SVPLKdeb2dsMi7s2GryLw1sIKI4BenUnAwpU3EzLNOFL2p1Rdc7BrWjWVJEc0ZpB
ASYlNSK5WFPPYlTbi8f2M9DyElVAm7gOuVUhGWjbsH+t7WQwc4WjAQupQUBw8xhe
aA2Pmn6JZHB8xNQOpZHsQIDqFv3NBfmiJ6FPvjvcXGpWJ3N08t/B2jV7xpc4qNCG
ti8JCeu4YpN+iEtg16NEqEX8fm+oWGuMZhzt/swanHSxzXt4vKSXZIXjgy5jwCSQ
drFkjiRdPfQTBlmTb5lwiz2QCYomGaakWAKB1W33/I/y1ngr88KYDSwoTCpVqaVb
dp5flDYpV12RcE8LcTtqc7x3F29pRl59E5R4ld1gkmIQ4NwKjBoLP6zLXqwfa9Ry
Ojnza6Wa3V+cOT6UPko4
=G9nk
-----END PGP SIGNATURE-----

--pWyiEgJYm5f9v55/--
