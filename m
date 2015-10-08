From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth-next 2015-10-08
Date: Thu, 8 Oct 2015 17:00:58 +0300
Message-ID: <20151008140058.GA21971@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zYM0uCDKw75PZbzx"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's another set of Bluetooth & 802.15.4 patches for the 4.4 kernel.

802.15.4:
 - Many improvements & fixes to the mrf24j40 driver
 - Fixes and cleanups to nl802154, mac802154 & ieee802154 code

Bluetooth:
 - New chipset support in btmrvl driver
 - Fixes & cleanups to btbcm, btmrvl, bpa10x & btintel drivers
 - Support for vendor specific diagnostic data through common API
 - Cleanups to the 6lowpan code
 - New events & message types for monitor channel

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 97170ea1823bf00cf6ed0f503129e9053a66c53a:

  drivers/net/ieee802154/at86rf230.c: seq_printf() now returns NULL (2015-09-21 20:41:44 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to f640ee98bbeaa169684a571e0b96bea563bb6015:

  Bluetooth: Fix basic debugfs entries for unconfigured controllers (2015-10-08 15:33:18 +0300)

----------------------------------------------------------------
Alexander Aring (42):
      mac802154: llsec: fix device deletion from list
      ieee802154: header_ops: fix frame control setting
      ieee802154: introduce wpan_dev_header_ops
      ieee802154: change needed headroom/tailroom
      mac802154: tx: add warning if MTU exceeds
      at86rf230: support edge triggered irq
      mrf24j40: cleanup define identation
      mrf24j40: use ieee802154_alloc_hw for private data
      mrf24j40: calling ieee802154_register_hw at last
      mrf24j40: remove spi settings overwrite
      mrf24j40: add device-tree support
      mrf24j40: add default channel setting
      mrf24j40: add random extended addr generation
      mrf24j40: add more register defines
      mrf24j40: add regmap support
      mrf24j40: use regmap for register access
      mrf24j40: change to frame delivery with crc
      ieee802154: add helpers for frame control checks
      mrf24j40: rework tx handling to async tx handling
      mrf24j40: rework rx handling to async rx handling
      mrf24j40: async interrupt handling
      mrf24j40: add csma params support
      mrf24j40: add cca mode support
      mrf24j40: add cca ed level support
      mrf24j40: add tx power support
      mrf24j40: add promiscuous mode support
      mrf24j40: change irq trigger type behaviour
      mrf24j40: replace magic numbers
      mrf24j40: remove trailing semicolon
      ieee802154: remove unnecessary includes
      mac802154: iface: assume big endian for af_packet
      netlink: add nla_get for le32 and le64
      nl802154: use nla_get_le64 for get extended addr
      nl802154: add support for security layer
      mac802154: add comments for llsec issues
      ieee802154: change mtu size behaviour
      mac802154: check on len instead mac_len
      ieee802154: 6lowpan: change datagram var types
      ieee802154: 6lowpan: don't skip first dsn while fragmentation
      ieee802154: 6lowpan: add tx/rx stats
      ieee802154: handle datagram variables as u16
      6lowpan: move shared settings to lowpan_netdev_setup

Amitkumar Karwar (2):
      Bluetooth: btmrvl: remove extra space in cast
      Bluetooth: btmrvl: add sd8997 chipset support

Dan Carpenter (1):
      nl802154: Missing return in nl802154_add_llsec_key()

Frederic Danis (5):
      Bluetooth: Add BT_WARN and bt_dev_warn logging macros
      Bluetooth: hci_bcm: Fix IRQ polarity for T100
      Bluetooth: hci_bcm: Prepare PM runtime support
      Bluetooth: Remove useless rx_lock spinlock
      Bluetooth: hci_bcm: Add suspend/resume runtime PM functions

Jarkko Nikula (6):
      Bluetooth: hci_intel: Cleanup the device probe code
      Bluetooth: hci_bcm: Add missing acpi_dev_free_resource_list()
      Bluetooth: hci_bcm: Handle possible error from acpi_dev_get_resources()
      Bluetooth: hci_bcm: Remove needless acpi_match_device() call
      Bluetooth: hci_bcm: Remove needless looking code
      Bluetooth: hci_bcm: Do not test ACPI companion in bcm_acpi_probe()

Johan Hedberg (6):
      Bluetooth: 6lowpan: Fix imtu & omtu values
      Bluetooth: 6lowpan: Remove redundant (and incorrect) MPS assignments
      Bluetooth: 6lowpan: Remove redundant BT_CONNECTED assignment
      Bluetooth: 6lowpan: Remove unnecessary chan_open() function
      Bluetooth: 6lowpan: Rename confusing 'pchan' variables
      Bluetooth: 6lowpan: Remove unnecessary chan_get() function

Loic Poulain (2):
      Bluetooth: Add hci_cmd_sync function
      Bluetooth: btintel: Add iBT register access over HCI support

Marcel Holtmann (18):
      Bluetooth: btbcm: Send HCI Reset before sending Apple specific commands
      Bluetooth: Limit userspace exposure of stack internal events
      Bluetooth: Introduce HCI_DEV_OPEN and HCI_DEV_CLOSE events
      Bluetooth: Move HCI_RUNNING check into hci_send_frame
      Bluetooth: Move handling of HCI_RUNNING flag into core
      Bluetooth: Send transport open and close monitor events
      Bluetooth: btbcm: Read the local name in setup stage
      Bluetooth: Send index information updates to monitor channel
      Bluetooth: Add support for vendor specific diagnostic channel
      Bluetooth: hci_bcm: Enable parsing of LM_DIAG messages
      Bluetooth: Add debugfs entry for setting vendor diagnostic mode
      Bluetooth: hci_bcm: Enable support for set_diag driver callback
      Bluetooth: Fix interaction of HCI_QUIRK_RESET_ON_CLOSE and HCI_AUTO_OFF
      Bluetooth: bpa10x: Read revision information in setup stage
      Bluetooth: bpa10x: Add support for set_diag driver callback
      Bluetooth: bpa10x: Use h4_recv_buf helper for frame reassembly
      Bluetooth: Enforce packet types in hci_recv_frame driver function
      Bluetooth: Fix basic debugfs entries for unconfigured controllers

Nachiket Kukade (1):
      Bluetooth: btmrvl: fix firmware dump issue

Prasanna Karthik (7):
      Bluetooth: bluecard: Comparison to NULL could be re-written
      Bluetooth: bt3c_cs: Comparison to NULL re-written
      Bluetooth: btuart_cs: Comparison to NULL re-written
      Bluetooth: btmrvl: Comparison to NULL re-written
      Bluetooth: hci_qca: Changed unsigned long to bool
      Bluetooth: btuart_cs: remove obsolete header
      Bluetooth: hci_h5: clean up hci_h5 code

 .../bindings/net/ieee802154/mrf24j40.txt           |   20 +
 MAINTAINERS                                        |    1 +
 drivers/bluetooth/Kconfig                          |    6 +-
 drivers/bluetooth/bfusb.c                          |   11 -
 drivers/bluetooth/bluecard_cs.c                    |    8 +-
 drivers/bluetooth/bpa10x.c                         |  186 +--
 drivers/bluetooth/bt3c_cs.c                        |    8 +-
 drivers/bluetooth/btbcm.c                          |   54 +-
 drivers/bluetooth/btintel.c                        |  196 +++
 drivers/bluetooth/btintel.h                        |    9 +
 drivers/bluetooth/btmrvl_main.c                    |   14 +-
 drivers/bluetooth/btmrvl_sdio.c                    |   54 +-
 drivers/bluetooth/btsdio.c                         |   14 +-
 drivers/bluetooth/btuart_cs.c                      |   10 +-
 drivers/bluetooth/btusb.c                          |   13 -
 drivers/bluetooth/btwilink.c                       |   13 -
 drivers/bluetooth/dtl1_cs.c                        |    5 -
 drivers/bluetooth/hci_bcm.c                        |  239 +++-
 drivers/bluetooth/hci_h4.c                         |    1 +
 drivers/bluetooth/hci_h5.c                         |   10 +-
 drivers/bluetooth/hci_intel.c                      |   24 -
 drivers/bluetooth/hci_ldisc.c                      |   17 +-
 drivers/bluetooth/hci_qca.c                        |    4 +-
 drivers/bluetooth/hci_uart.h                       |    1 -
 drivers/bluetooth/hci_vhci.c                       |    8 -
 drivers/net/ieee802154/Kconfig                     |    1 +
 drivers/net/ieee802154/at86rf230.c                 |  211 ++-
 drivers/net/ieee802154/mrf24j40.c                  | 1424 +++++++++++++------
 include/linux/ieee802154.h                         |   22 +-
 include/net/6lowpan.h                              |   10 +
 include/net/bluetooth/bluetooth.h                  |    5 +
 include/net/bluetooth/hci.h                        |    4 +
 include/net/bluetooth/hci_core.h                   |    5 +
 include/net/bluetooth/hci_mon.h                    |   10 +
 include/net/cfg802154.h                            |  164 +++
 include/net/ieee802154_netdev.h                    |   86 +-
 include/net/mac802154.h                            |   10 +-
 include/net/netlink.h                              |   18 +
 include/net/nl802154.h                             |  191 +++
 net/6lowpan/core.c                                 |    5 +
 net/6lowpan/nhc.h                                  |    2 -
 net/bluetooth/6lowpan.c                            |   78 +-
 net/bluetooth/hci_core.c                           |  142 +-
 net/bluetooth/hci_sock.c                           |   70 +-
 net/bluetooth/lib.c                                |   16 +
 net/ieee802154/6lowpan/core.c                      |   18 +-
 net/ieee802154/6lowpan/rx.c                        |    2 +
 net/ieee802154/6lowpan/tx.c                        |   49 +-
 net/ieee802154/Kconfig                             |    5 +
 net/ieee802154/core.c                              |   12 +
 net/ieee802154/core.h                              |    1 +
 net/ieee802154/header_ops.c                        |   20 +-
 net/ieee802154/nl802154.c                          | 1321 +++++++++++++++--
 net/ieee802154/rdev-ops.h                          |  109 ++
 net/ieee802154/socket.c                            |    8 +-
 net/mac802154/cfg.c                                |  205 +++
 net/mac802154/iface.c                              |  118 +-
 net/mac802154/llsec.c                              |    1 +
 net/mac802154/rx.c                                 |    4 +
 net/mac802154/tx.c                                 |    7 +-
 60 files changed, 4079 insertions(+), 1201 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/ieee802154/mrf24j40.txt

--zYM0uCDKw75PZbzx
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWFncaAAoJECQj9vv5qNQSflcP/Auufd9P+0CCFi6c8HYf999d
JW02kpP3A+tJOabe6Mj5i++KOk9jzE9AlmkyYwGK+hX3j/SoNTay60HfH6JsOsCw
06UE6m92R3Tp2y3TucbJ406rA9L+DNFecGhR9pRgE24Xz0wF/80/+fsKyMr9oi/5
rERent3cK+YcRoezadyNCInK7Faj5yrvADsc/ukIYJA+t94sueCHsRBkDLvH5I79
4NJt6Uc8i9eZKFZfAhtgYRpKP7mXyTlD81XxwQ9KHLyoTosfGuCjgV2yh+2d+nYD
lVrSJ0hPseRX77fvb1wCiuiNChuenjj4EHpzN2zubRSfAFKSjIudU+scXA6ghdhk
iDtYEyKWcHlO8FGOhCKacN/BXZf5HWanFuVrNh4Rpx9p5SzP4TpzTgfVJbo0H4pz
yaZ+bgw1DoYCTCN9eAv0LqpmTZG7Q3aZFYdBYAD7wOGd6K9gruMheHeCg+jfYy0i
VjbcW+H6j/zf2JlAGWrScpAYr89uOg0VK9jC/eIhG/CuY/ebYcsyQt+EzwQxs5md
CVDCsoulprHQuOrFJ9ri3+9QogWY2Jt10kovxtQBiQOnd2IZikIZXbsipUXlmsoT
63zLOKlYDvoGTx6EL2ELedZeVxWff3IpRy+YyJp5KFJ0/Yl7RQwbCtnBYjBOR1ZA
LQQ7SZodcXMt4QmVovbN
=gHGn
-----END PGP SIGNATURE-----

--zYM0uCDKw75PZbzx--
