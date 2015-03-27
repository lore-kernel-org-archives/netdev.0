From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth-next 2015-03-27
Date: Fri, 27 Mar 2015 20:40:58 +0200
Message-ID: <20150327184058.GA10609@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ikeVEW9yuYc//A+q"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--ikeVEW9yuYc//A+q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's another set of Bluetooth & 802.15.4 patches for 4.1:

 - New API to control LE advertising data (i.e. peripheral role)
 - mac802154 & at86rf230 cleanups
 - Support for toggling quirks from debugfs (useful for testing)
 - Memory leak fix for LE scanning
 - Extra version info reading support for Broadcom controllers

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit ea6edfbcefec1fcfdb826a1d5a054f402dfbfb24:

  mac802154: fix typo in header guard (2015-03-19 15:32:22 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to a7a484bfca218f9671a3e3bc98851eab6b628310:

  at86rf230: fix is_tx while error handling (2015-03-27 19:18:51 +0100)

----------------------------------------------------------------
Alexander Aring (3):
      mac802154: cleanup concurrent check
      at86rf230: remove unnecessary spinlock
      at86rf230: fix is_tx while error handling

Arman Uguray (15):
      Bluetooth: Add definitions for Add/Remove Advertising API
      Bluetooth: Introduce HCI_ADVERTISING_INSTANCE setting and add AD flags
      Bluetooth: Add data structure for advertising instance
      Bluetooth: Implement the Add Advertising command
      Bluetooth: Implement the Remove Advertising command
      Bluetooth: Add support for instance scan response
      Bluetooth: Add support for adv instance timeout
      Bluetooth: Add macros for advertising instance flags
      Bluetooth: Support the "connectable mode" adv flag
      Bluetooth: Support the "discoverable" adv flag
      Bluetooth: Support the "limited-discoverable" adv flag
      Bluetooth: Support the "managed-flags" adv flag
      Bluetooth: Support the "tx-power" adv flag
      Bluetooth: Update supported_flags for AD features
      Bluetooth: Unify advertising data code paths

Jakub Pawlowski (1):
      Bluetooth: Expose quirks through debugfs

Johan Hedberg (1):
      Bluetooth: Fix memory leak in le_scan_disable_work_complete()

Loic Poulain (1):
      Bluetooth: hci_uart: Add setup callback

Marcel Holtmann (6):
      Bluetooth: Gracefully response to enabling LE on LE only devices
      Bluetooth: Use HCI_MAX_AD_LENGTH constant instead hardcoded value
      Bluetooth: Read Verbose Config Version Info for Broadcom devices
      Bluetooth: Read Broadcom chip info for Apple Bluetooth devices
      Bluetooth: Filter list of supported commands/events for untrusted users
      Bluetooth: Fix minor typo in comment for static address setting

 drivers/bluetooth/btusb.c          |  57 ++-
 drivers/bluetooth/hci_ldisc.c      |  11 +
 drivers/bluetooth/hci_uart.h       |   1 +
 drivers/net/ieee802154/at86rf230.c |  10 +-
 include/net/bluetooth/hci.h        |   2 +
 include/net/bluetooth/hci_core.h   |  18 +
 include/net/bluetooth/mgmt.h       |  42 +++
 net/bluetooth/hci_core.c           |  18 +-
 net/bluetooth/hci_debugfs.c        |  60 +++
 net/bluetooth/mgmt.c               | 715 +++++++++++++++++++++++++++++++++---
 net/mac802154/iface.c              |  20 +-
 11 files changed, 862 insertions(+), 92 deletions(-)


--ikeVEW9yuYc//A+q
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVFaQ6AAoJECQj9vv5qNQSFcQP/3vKUeQaE3N4zUwiVoolQl/U
5dVDUVyiNBfzv/MnEsptFg+7LFrMp0YmRyZOaG9c6eyTcEmmwkbMCQLwHQmulx5B
Nq6WVNYwjCAeKvX/vs71EfXGxB99UUS6VJ561NNbw3l9SxyPK3YIodYFnc8gUha7
YTuRl6r1ySM5c+Wj2EIPb/Nbo4RXmtwiUTZQguqmUWILitO2Y6uhu9bJ/sACuPmJ
h5xoZqn1Vr9/B0sFH9/WMG8TvEi6iNIQ1ncnUq+VhNr3vBvyUYDNAYieihyWzMcy
MbFhiIE3thBl5aMIQ0jxwTWSTbtLWFyelzqwskvOQcXrkfIVCtd/LINsB5uaUeYC
zlBCe93I0cnDY0vtROMa/QO8q2efuHeQVR1ku4SbunvtpAJo04Z1etpf5zY4wy+D
96x4JIRAQjUL3m9w0jNKYUdBbybCK210nB62yRgYMJmBG+IAyJUJbVDJ9YcvrXrv
rnXrxsaIKTyCpnMDAp//rBpvdFEXVAdY48mAa52n26bpFouylImW5wnPorHykzGV
BSPl7uxJB1Dq7/hKWpnW5i6LwSyYXCtrG/Y0cOw9gedIVLtkf6EI1aMSa4dAEE2F
RdhvhCfYWXT3kLM9LNSrvsrNuvQ5jClbCLkiOhKaPuYslKuVu9fPuTVcsqIGXtyv
U3kRy9l0GDzABLgvxtub
=8uUF
-----END PGP SIGNATURE-----

--ikeVEW9yuYc//A+q--
