From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2017-04-14
Date: Fri, 14 Apr 2017 21:12:12 +0300
Message-ID: <20170414181212.GA27363@x1c.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="4Ckj6UjgE2iN1+kY"
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:34522 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751696AbdDNSMW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 14:12:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's the main batch of Bluetooth & 802.15.4 patches for the 4.12
kernel.

 - Many fixes to 6LoWPAN, in particular for BLE
 - New CA8210 IEEE 802.15.4 device driver (accounting for most of the
   lines of code added in this pull request)
 - Added Nokia Bluetooth (UART) HCI driver
 - Some serdev & TTY changes that are dependencies for the Nokia
   driver (with acks from relevant maintainers and an agreement that
   these come through the bluetooth tree)
 - Support for new Intel Bluetooth device
 - Various other minor cleanups/fixes here and there

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit d92be7a41ef15463eb816a4a2d42bf094b56dfce:

  net: make struct net_device::min_header_len 8-bit (2017-04-12 13:59:21 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 019aa56b7df8a796b2c01a56269a370ad3442ec7:

  arm64: dts: hikey: add WL1835 Bluetooth device node (2017-04-13 19:22:53 +0200)

----------------------------------------------------------------
Alexander Aring (2):
      6lowpan: iphc: override l2 packet information
      ipv6: addrconf: fix 48 bit 6lowpan autoconfiguration

Andy Shevchenko (1):
      Bluetooth: hci_bcm: Support platform enumeration

Colin Ian King (4):
      Bluetooth: btmrvl: fix spelling mistake: "unregester" -> "unregister"
      Bluetooth: fix assignments on error variable err
      6lowpan: fix assignment of peer_addr
      ieee802154: ca8210: Add checks for kmalloc allocation failures

Dean Jenkins (2):
      Bluetooth: Handle bt_accept_enqueue() socket atomically
      Bluetooth: Avoid bt_accept_unlink() double unlinking

Elena Reshetova (1):
      Bluetooth: convert rfcomm_dlc.refcnt from atomic_t to refcount_t

Gabriel (1):
      Bluetooth: Added support for Rivet Networks Killer 1535

Geliang Tang (1):
      Bluetooth: bluecard: use setup_timer

Harry Morris (3):
      ieee802154: Add CA8210 IEEE 802.15.4 device driver
      ieee802154: Add device tree documentation for CA8210
      ieee802154: Add entry in MAINTAINTERS for CA8210 driver

Jeffy Chen (2):
      Bluetooth: btusb: wake system up when receives a wake irq
      Bluetooth: btmrvl: wake system up when receives a wake irq

Johan Hovold (2):
      Bluetooth: hci_bcm: add missing tty-device sanity check
      Bluetooth: hci_intel: add missing tty-device sanity check

John Keeping (1):
      Bluetooth: hci_bcm: Fix clock (un)prepare

Jonas Holmberg (1):
      Bluetooth: Change initial min and max interval

Larry Finger (1):
      Bluetooth: btrtl: Change message for missing config file

Luiz Augusto von Dentz (10):
      6lowpan: Use netdev addr_len to determine lladdr len
      6lowpan: Fix IID format for Bluetooth
      Bluetooth: 6lowpan: Remove unnecessary peer lookup
      Bluetooth: 6lowpan: Print errors during recv_pkt
      Bluetooth: L2CAP: Don't return -EAGAIN if out of credits
      6lowpan: Don't set IFF_NO_QUEUE
      Bluetooth: 6lowpan: Don't drop packets when run out of credits
      Bluetooth: 6lowpan: Use netif APIs to flow control
      Bluetooth: L2CAP: Add l2cap_le_flowctl_send
      Bluetooth: 6lowpan: Set tx_queue_len to DEFAULT_TX_QUEUE_LEN

Marcel Holtmann (1):
      Bluetooth: btusb: Add support for Intel Bluetooth devices 9160/9260 [8087:0025]

Marcin Kraglak (1):
      Bluetooth: L2CAP: Fix L2CAP_CR_SCID_IN_USE value

Michael Scott (2):
      Bluetooth: 6lowpan: fix delay work init in add_peer_chan()
      Bluetooth: 6lowpan: fix use after free in chan_suspend/resume

Patrik Flykt (3):
      bluetooth: Set 6 byte device addresses
      6lowpan: Set MAC address length according to LOWPAN_LLTYPE
      bluetooth: Do not set IFF_POINTOPOINT

Rob Herring (5):
      Bluetooth: hci_uart: add serdev driver support library
      dt-bindings: net: Add TI WiLink shared transport binding
      bluetooth: hci_uart: remove unused hci_uart_init_tty
      bluetooth: hci_uart: add LL protocol serdev driver support
      arm64: dts: hikey: add WL1835 Bluetooth device node

Sebastian Reichel (9):
      tty: serial: omap: add UPF_BOOT_AUTOCONF flag for DT init
      serdev: add serdev_device_wait_until_sent
      serdev: implement get/set tiocm
      serdev: add helpers for cts and rts handling
      Bluetooth: hci_uart: add support for word alignment
      Bluetooth: hci_serdev: do not open device in hci open
      Bluetooth: hci_serdev: allow modular drivers
      dt-bindings: net: bluetooth: Add nokia-bluetooth
      Bluetooth: add nokia driver

Tedd Ho-Jeong An (3):
      Bluetooth: Use switch statement for Intel hardware variants
      Bluetooth: hci_intel: Fix firmware file name to use hw_variant
      Bluetooth: hci_intel: Add support Intel Bluetooth device 9160/9260 for UART

Xinming Hu (2):
      Bluetooth: btmrvl: disable platform wakeup interrupt in suspend failure path
      Bluetooth: btmrvl: remove unnecessary wakeup interrupt number sanity check

prasanna karthik (1):
      Bluetooth: btmrvl: cleanup code in return from btmrvl_sdio_suspend()

 .../devicetree/bindings/net/ieee802154/ca8210.txt  |   28 +
 .../devicetree/bindings/net/nokia-bluetooth.txt    |   51 +
 .../devicetree/bindings/net/ti,wilink-st.txt       |   35 +
 .../devicetree/bindings/vendor-prefixes.txt        |    1 +
 MAINTAINERS                                        |    9 +
 arch/arm64/boot/dts/hisilicon/hi6220-hikey.dts     |    5 +
 drivers/bluetooth/Kconfig                          |   12 +
 drivers/bluetooth/Makefile                         |    3 +
 drivers/bluetooth/bluecard_cs.c                    |    5 +-
 drivers/bluetooth/btmrvl_sdio.c                    |   32 +-
 drivers/bluetooth/btrtl.c                          |   13 +-
 drivers/bluetooth/btusb.c                          |   15 +-
 drivers/bluetooth/hci_bcm.c                        |   59 +-
 drivers/bluetooth/hci_h4.c                         |   17 +
 drivers/bluetooth/hci_intel.c                      |   47 +-
 drivers/bluetooth/hci_ldisc.c                      |   24 +-
 drivers/bluetooth/hci_ll.c                         |  262 +-
 drivers/bluetooth/hci_nokia.c                      |  820 +++++
 drivers/bluetooth/hci_serdev.c                     |  356 +++
 drivers/bluetooth/hci_uart.h                       |    8 +-
 drivers/net/ieee802154/Kconfig                     |   22 +
 drivers/net/ieee802154/Makefile                    |    1 +
 drivers/net/ieee802154/ca8210.c                    | 3242 ++++++++++++++++++++
 drivers/tty/serdev/core.c                          |   33 +
 drivers/tty/serdev/serdev-ttyport.c                |   42 +-
 drivers/tty/serial/omap-serial.c                   |    3 +
 include/linux/serdev.h                             |   47 +
 include/net/6lowpan.h                              |   15 +
 include/net/bluetooth/l2cap.h                      |    2 +-
 include/net/bluetooth/rfcomm.h                     |    8 +-
 net/6lowpan/core.c                                 |   12 +-
 net/6lowpan/iphc.c                                 |   57 +-
 net/bluetooth/6lowpan.c                            |  192 +-
 net/bluetooth/af_bluetooth.c                       |   26 +
 net/bluetooth/amp.c                                |   10 +-
 net/bluetooth/hci_core.c                           |    4 +-
 net/bluetooth/l2cap_core.c                         |   30 +-
 net/bluetooth/rfcomm/core.c                        |    4 +-
 net/ipv6/addrconf.c                                |   23 +-
 39 files changed, 5309 insertions(+), 266 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/ieee802154/ca8210.txt
 create mode 100644 Documentation/devicetree/bindings/net/nokia-bluetooth.txt
 create mode 100644 Documentation/devicetree/bindings/net/ti,wilink-st.txt
 create mode 100644 drivers/bluetooth/hci_nokia.c
 create mode 100644 drivers/bluetooth/hci_serdev.c
 create mode 100644 drivers/net/ieee802154/ca8210.c

--4Ckj6UjgE2iN1+kY
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJY8RD8AAoJECQj9vv5qNQStf0QAJKzfL9LQACVkhJqi3LS7H2D
uJRXPJcx0Y61xcPRWZ9UecXjbciMPx98R0q9LTMTM9i07Q/2Gc8uLdz4xIL4e/2F
n5meZhf1+gxfKYWlG1fWfaVvMyThUUYGSpp2m9N9nPxPLpxR6ZhWDSlqm0TstPQ6
Vbtsv8LzkIL8/7KSCGHKYT0crAbf/Z829+SNGeDB3TD8pSXLlITS4extFur1wKsE
/nt2ZoT9nUbQcM99jYbhQ9iAL4xrBWEykz9Jtz6Yj+FRJ6FvSw5XRsjl8MZaXBtZ
RtqPZQjU+MrdjsnCD2odGsgdJoWMeRK6fOu4isbJMs6eicYzYhi/yrkIXpPtU/TA
JgO8+hg5d3KW/d20xZ7ovSSoSmCKIdIDm7Q4Edk6s6IBTko7RWc/Ch9yOGKS3M33
B7afo2PSJaZOV6kTYV7SASVKeYk/HMZPWeFs1EVETzumwWa/T/aCbsTogifiryeT
PbaR/XZEtiL/LY+DwLMnSD/LGDjAenLN/SDeH/sttNe7lCE439twttERB/Ix+Jg/
mCm0H0bjnDUIlO/XjhbA/n/7sqD1Sel2R9ZicfmSLp+08rRwFD/Mv5nkYb7Xv2Rs
n0L/ThVjCbBPK9bH0/EBASJTh2Jt92r6OW/qnxD/ZVG7eyEQ8Y/HW0wR0cLJIUgk
nd0wYpMXdRhTueLkZ3W5
=EqXF
-----END PGP SIGNATURE-----

--4Ckj6UjgE2iN1+kY--
