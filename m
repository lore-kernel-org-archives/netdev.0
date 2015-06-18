From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2015-06-18
Date: Thu, 18 Jun 2015 21:43:11 +0300
Message-ID: <20150618184311.GA30772@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="rwEMma7ioTxnRzrJ"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:34604 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755654AbbFRSnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 14:43:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's the final bluetooth-next pull request for 4.2.

 - Cleanups & fixes to 802.15.4 code and related drivers
 - Fix btusb driver memory leak
 - New USB IDs for Atheros controllers
 - Support for BCM4324B3 UART based Broadcom controller
 - Fix for Bluetooth encryption key size handling
 - Broadcom controller initialization fixes
 - Support for Intel controller DDC parameters
 - Support for multiple Bluetooth LE advertising instances
 - Fix for HCI user channel cleanup path

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit a9ab2184f451ec78af245ebb8b663d8700d44672:

  Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge (2015-05-31 01:07:06 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 952497b159468477392f9b562b904da9bc76d468:

  Bluetooth: Fix warning of potentially uninitialized adv_instance variable (2015-06-18 21:05:31 +0300)

----------------------------------------------------------------
Aleksei Volkov (1):
      Bluetooth: btusb: Correct typo in Roper Class 1 Bluetooth Dongle

Alexander Aring (20):
      ieee802154: 6lowpan: set ackreq when needed
      mac802154: remove unneeded vif struct
      mac802154: cleanup address filtering flags
      mac802154: remove aack hw flag
      mac802154: cleanup ieee802154 hardware flags
      mac802154: remove unused hw_filt attribute
      mac802154: rearrange attribute in ieee802154_hw
      mac802154: add missing structure comments
      mac802154: change pan_coord type to bool
      mac802154: fix flags BIT definitions order
      mac802154: iface: fix hrtimer cancel on ifdown
      mac802154: iface: flush workqueue before stop
      at86rf230: use level high as fallback default
      at86rf230: add support for sleep state
      fakelb: add xmit_async after stop testcase
      at86rf230: fix phy settings while sleeping
      at86rf230: add recommended csma backoffs settings
      at86rf230: cleanup start and stop callbacks
      mac802154: iface: fix order while interface up
      mac802154: iface: cleanup stack variable

Alexey Dobriyan (1):
      Bluetooth: Stop sabotaging list poisoning

Arron Wang (2):
      Bluetooth: Make l2cap_recv_acldata() and sco_recv_scodata() return void
      Bluetooth: Move SCO support under BT_BREDR config option

Chan-yeol Park (1):
      Bluetooth: hci_uart: Fix dereferencing of ERR_PTR

Christoffer Holmstedt (1):
      nl802154: fix misspelled enum

Dmitry Tunin (3):
      ath3k: Add support of 0489:e076 AR3012 device
      ath3k: add support of 13d3:3474 AR3012 device
      Bluetooth: ath3k: Add support of 04ca:300d AR3012 device

Florian Grandel (20):
      Bluetooth: hci_core/mgmt: Introduce multi-adv list
      Bluetooth: hci_core/mgmt: move adv timeout to hdev
      Bluetooth: mgmt: dry update_scan_rsp_data()
      Bluetooth: mgmt: rename update_*_data_for_instance()
      Bluetooth: mgmt: multi adv for read_adv_features()
      Bluetooth: mgmt: multi adv for get_current_adv_instance()
      Bluetooth: mgmt: multi adv for get_adv_instance_flags()
      Bluetooth: mgmt: improve get_adv_instance_flags() readability
      Bluetooth: mgmt: multi adv for enable_advertising()
      Bluetooth: mgmt: multi adv for create_instance_scan_rsp_data()
      Bluetooth: mgmt: multi adv for create_instance_adv_data()
      Bluetooth: mgmt: multi adv for set_advertising*()
      Bluetooth: mgmt: multi adv for clear_adv_instances()
      Bluetooth: mgmt/hci_core: multi-adv for add_advertising*()
      Bluetooth: mgmt: multi adv for remove_advertising*()
      Bluetooth: mgmt: program multi-adv on power on
      Bluetooth: mgmt: multi-adv for trigger_le_scan()
      Bluetooth: mgmt: multi-adv for mgmt_reenable_advertising()
      Bluetooth: hci_core: remove obsolete adv_instance
      Bluetooth: hci_core: increase max adv inst

Frederic Danis (7):
      Bluetooth: btbcm: Move request/release_firmware()
      Bluetooth: btbcm: Add BCM4324B3 UART device
      Bluetooth: hci_uart: Support operational speed during setup
      Bluetooth: btbcm: Add helper functions for UART setup
      Bluetooth: hci_uart: Update Broadcom UART setup
      Bluetooth: hci_uart: Add bcm_set_baudrate()
      Bluetooth: hci_uart: Fix speed selection

Glenn Ruben Bakke (5):
      Bluetooth: 6lowpan: Enable delete_netdev to be scheduled when last peer is deleted
      Bluetooth: 6lowpan: Rename ambiguous variable
      Bluetooth: 6lowpan: Move netdev sysfs device reference
      Bluetooth: 6lowpan: Fix double kfree of netdev priv
      Bluetooth: 6lowpan: Fix module refcount

Ilya Faenson (2):
      Bluetooth: btbcm: Support the BCM4354 Bluetooth UART device
      Bluetooth: hci_uart: Add new line discipline enhancements

Jaganath Kanakkassery (1):
      Bluetooth: Fix potential NULL dereference in RFCOMM bind callback

Johan Hedberg (10):
      Bluetooth: Fix encryption key size handling for LTKs
      Bluetooth: Fix exposing full value of shortened LTKs
      Bluetooth: Add debugfs support for max LE encryption key size
      Bluetooth: Add debugfs support for min LE encryption key size
      Bluetooth: Move SC-only check outside of BT_CONFIG branch
      Bluetooth: Read encryption key size for BR/EDR connections
      Bluetooth: Use actual encryption key size for SMP over BR/EDR
      Bluetooth: Remove redundant check for ACL_LINK
      Bluetooth: Use zalloc when possible
      Bluetooth: Fix warning of potentially uninitialized adv_instance variable

Lennert Buytenhek (3):
      ieee802154: Fix generation of random EUI-64 addresses.
      ieee802154: Fix EUI-64 station address validation.
      ieee802154: Fix sockaddr_ieee802154 implicit padding information leak.

Loic Poulain (2):
      Bluetooth: Reorder HCI user channel socket release
      Bluetooth: Don't call shutdown when leaving user channel

Marcel Holtmann (6):
      Bluetooth: Fix race condition with user channel and setup stage
      Bluetooth: btusb: Fix memory leak in Intel setup routine
      Bluetooth: btusb: Remove double error check from local version command
      Bluetooth: btusb: Remove unneeded btusb_read_local_version function
      Bluetooth: btusb: Fix secure send command length alignment on Intel 8260
      Bluetooth: Increment management interface revision

Prasanna Karthik (3):
      Bluetooth: vhci: Clean up coding style fix
      Bluetooth: hci_bcsp: Clean up code Fix
      Bluetooth: bt3c_cs: Fix coding style -- clean up

Stefan Schmidt (7):
      ieee802154/atusb: Add function for partial register writes
      ieee802154/atusb: Add .set_txpower operation to the driver
      ieee802154/atusb: Add .set_promiscuous_mode driver operation
      MAINTAINERS: Add myself as maintainer for the atusb driver
      mac802154/iface: remove superfluous WARN_ON call in slave_open()
      ieee802154/mrf24j40: make sure we do not override return values
      ieee802154: cc2520: check for return values in cc2520_filter()

Tedd Ho-Jeong An (1):
      Bluetooth: btusb: Add routine for applying Intel DDC parameters

Varka Bhadram (10):
      cc2520: fix in default tx power setting
      cc2520: fix CC2591 handling
      cc2520: add set transmit power setting support
      cc2520: update initial transmit power value
      cc2520: update current channel
      mac802154: add trace functionality for driver ops
      cfg802154: fix rdev-ops naming convension and format specifiers
      nl802154: export supported commands
      mac802154: cleanup llsec param flags
      mac802154: rx packet handle cleanup

 MAINTAINERS                        |   8 +
 drivers/bluetooth/ath3k.c          |   6 +
 drivers/bluetooth/bt3c_cs.c        |   3 +-
 drivers/bluetooth/btbcm.c          | 132 ++++++++-
 drivers/bluetooth/btbcm.h          |  61 +++-
 drivers/bluetooth/btusb.c          | 148 ++++++----
 drivers/bluetooth/hci_ath.c        |   1 +
 drivers/bluetooth/hci_bcm.c        | 107 ++++++-
 drivers/bluetooth/hci_bcsp.c       |  16 +-
 drivers/bluetooth/hci_h4.c         |   1 +
 drivers/bluetooth/hci_ldisc.c      | 123 ++++++++
 drivers/bluetooth/hci_uart.h       |  11 +
 drivers/bluetooth/hci_vhci.c       |   2 +-
 drivers/net/ieee802154/at86rf230.c | 112 ++++++-
 drivers/net/ieee802154/atusb.c     | 101 +++++--
 drivers/net/ieee802154/cc2520.c    | 151 ++++++++--
 drivers/net/ieee802154/fakelb.c    |   5 +
 drivers/net/ieee802154/mrf24j40.c  |  10 +-
 include/linux/ieee802154.h         |  16 +-
 include/linux/spi/cc2520.h         |   1 -
 include/net/bluetooth/bluetooth.h  |  11 +
 include/net/bluetooth/hci.h        |  10 +
 include/net/bluetooth/hci_core.h   |  47 ++-
 include/net/ieee802154_netdev.h    |  18 +-
 include/net/mac802154.h            | 136 +++++----
 include/net/nl802154.h             |   6 +-
 net/bluetooth/6lowpan.c            |  13 +-
 net/bluetooth/Makefile             |   3 +-
 net/bluetooth/hci_conn.c           |   4 +-
 net/bluetooth/hci_core.c           | 148 +++++++++-
 net/bluetooth/hci_event.c          | 113 ++++++-
 net/bluetooth/hci_sock.c           |  30 +-
 net/bluetooth/l2cap_core.c         |  13 +-
 net/bluetooth/mgmt.c               | 570 +++++++++++++++++++++++++-----------
 net/bluetooth/rfcomm/sock.c        |  20 +-
 net/bluetooth/sco.c                |   5 +-
 net/bluetooth/smp.c                | 138 +++++++--
 net/ieee802154/6lowpan/tx.c        |   5 +-
 net/ieee802154/nl802154.c          |  40 +++
 net/ieee802154/socket.c            |   6 +
 net/ieee802154/trace.h             |  10 +-
 net/mac802154/Makefile             |   4 +-
 net/mac802154/driver-ops.h         |  92 +++++-
 net/mac802154/ieee802154_i.h       |   2 -
 net/mac802154/iface.c              | 126 ++++----
 net/mac802154/rx.c                 |   8 +-
 net/mac802154/trace.c              |   9 +
 net/mac802154/trace.h              | 272 +++++++++++++++++
 48 files changed, 2325 insertions(+), 549 deletions(-)
 create mode 100644 net/mac802154/trace.c
 create mode 100644 net/mac802154/trace.h

--rwEMma7ioTxnRzrJ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVgxE/AAoJECQj9vv5qNQSJ+8P/RvIUCDL2WKWf3HjH4X/C1Ly
6A3NK97v8Qjx4LqQYgtCGqw/4TwsIjo0Ai7SLstVn6/gpquTcszu8FuwPBNPAHUM
fCq1GWDkzesdaOoajywkHR94hvotHXoWsGDj+tRDbSFuo0cCIddzLSsz4UztyTKY
7DeogynctAcLB8kjnnh1LqSkvJbqHwrGk2i8o6THTkir4xS2ySW3OHM1DAE0F43x
fN430qS4ZoagpJmcfmhJ9OYs1Q43cfEodZRr2UvIuUzlRuHxhTKSZ5TmzE3SOO69
Iu0hUddP7IDia46RkyxIH0qUkQz0ArmSVmaNZNEnMCctJKni0uEHAlzAIynmrRH6
AUGAW7aACa6P22oQiBErm9sRJceTjwf3xyBBXLyMLdZMq2uAGJdw0PiC6FRICkiE
eIOcn3fYIoC3/r2ivRyW2Sdc4Evj0LTDXtUXBQdqPwaTSEMaKPQC1CvfebFNp4VM
adwDI/VL3uy8KzS3t4eUJHp2JHtIzmfmQSXxolLi2Yp/EbOBUk0CQ2T4O1bJDiyy
cYF93VqlwU/Ae9am39fqp4tdn1OUGMkpY7QB627zhaYRFfflFsKg2oBXHkNKT2Jf
EwDuy/4fYkKc1kiqnYBRgEmPual/L9GPJdG5bLu9Mqa4dA6g7PFLslzqt39Rw3GT
K2Uucb4QGmmXhiD6Q4Ff
=xc1l
-----END PGP SIGNATURE-----

--rwEMma7ioTxnRzrJ--
