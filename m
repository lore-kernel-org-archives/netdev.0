From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2014-03-31
Date: Mon, 31 Mar 2014 15:31:19 -0400
Message-ID: <20140331193118.GE17412@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="XsQoSWH+UP9D9v3l"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please accept this one last round of general wireless updates for
the 3.15 merge window!

For the Bluetooth bits, Gustavo says:

"Here follow another set of patches to 3.15. This is mostly a bug fix
pull request with the exception of one commit from Marcel which adds
tracking to the current configured LE scan type parameter."

Beyond that, notable bits include some final refactoring of rtl8180
and the addition of the rtl8187se driver, fixes for a number of
problems identified by Dan Carpenter and his static analysis tools,
and a handful of other bits here and there.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 9109e17f7c3ace48629397b44db5ce06bf168644:

  Merge branch 'filter-next' (2014-03-31 00:45:49 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 96da266e77637ae892b196f377908c51fa9f2d1a:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2014-03-31 15:22:17 -0400)

----------------------------------------------------------------

Adam Lee (2):
      rtlwifi: add MSI interrupts mode support
      rtlwifi: rtl8188ee: enable MSI interrupts mode

Alexey Khoroshilov (1):
      rtl8187: fix use after free on failure path in rtl8187_probe()

Amitkumar Karwar (8):
      Bluetooth: btmrvl: don't consume all vendor specific events
      mwifiex: corner case NULL pointer dereference fix
      mwifiex: correction in sleep confirm command sequence number
      mwifiex: cancel pending commands during host sleep
      mwifiex: scan command preparation failure handling
      mwifiex: cancel pending commands for signal
      mwifiex: use timeout variant for wait_event_interruptible
      mwifiex: fix spinlock bad magic bug

Andrea Merello (24):
      rtl8180: fix DMA register are written two times
      rtl8180: rationalize TX queues
      rtl818x: add registers for rtl8187se
      rtl8180: add rtl8187se chip type
      rtl8180: add rtl8187se fields to TX descriptor
      rtl8180: add basic rate configuration support for rtl8187se
      rtl8180: support for rtl8187se RX descriptors
      rtl8180: add ISR for rtl8187se
      rtl8180: introduce functions to enable/disable ints and add support f=
or rtl8187se
      rtl8180: don't write MAR registers for rtl8187se
      rtl8180: add TX queue mapping and support for rtl8187se
      rtl8180: config carbus register for rtl8187se
      rtl8180: add rtl8187se params to eeprom reading
      rtl8180: introduce functions for setting ANAPARAM 2 and 3 params
      rtl8180: add RF code for rtl8225 zebra v4
      rtl8180: add rtl8187se HW initialization
      rtl8180: add ERP configuration for rtl8187se
      rtl8180: make sure RTL818X_MSR_ENEDCA is set for rtl8187se
      rtl8180: add WMM parameters configuration for rtl8187se
      rtl8180: detect rtl8187se card
      rtl8180: enable rtl8187se support
      rtl818x: Update Kconfig for rtl8187se
      rtl8187: fix compile warning
      rtl8180: don't use weird trick to access "far" registers

Dan Carpenter (1):
      rsi: rsi_91x: misleading debug printk

Daniel Kim (1):
      brcmfmac: use mfp if required from user-space

Joe Perches (4):
      rtlwifi: Remove addressof casts to same type
      carl9170: Remove casts of pointer to same type
      mwifiex: Remove casts of pointer to same type
      rtlwifi: Remove casts of pointer to same type

Johan Hedberg (11):
      Bluetooth: Fix passkey endianess in user_confirm and notify_passkey
      Bluetooth: Fix address value for early disconnection events
      Bluetooth: Fix potential NULL pointer dereference in SMP
      Bluetooth: Add missing cmd_status handler for LE_Start_Encryption
      Bluetooth: Fix SMP confirmation callback handling
      Bluetooth: Add SMP flag to track which side is the initiator
      Bluetooth: Don't try to confirm locally initiated SMP pairing
      Bluetooth: Remove LTK re-encryption procedure
      Bluetooth: Fix potential NULL pointer dereference in smp_conn_security
      Bluetooth: Remove unnecessary assignment in SMP
      Bluetooth: Fix returning peer address in pending connect state

John W. Linville (2):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Marcel Holtmann (1):
      Bluetooth: Track current configured LE scan type parameter

Rafa=C5=82 Mi=C5=82ecki (1):
      bcma: gpio: register 32 GPIOs on BCM5357

Thomas Gleixner (1):
      Bluetooth: bluecard: Use del_timer_sync() in teardown path

 drivers/bcma/driver_gpio.c                         |   9 +-
 drivers/bluetooth/bluecard_cs.c                    |   2 +-
 drivers/bluetooth/btmrvl_main.c                    |  11 +-
 drivers/net/wireless/ath/carl9170/rx.c             |   2 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |  15 +-
 .../net/wireless/brcm80211/include/brcmu_wifi.h    |   3 +
 drivers/net/wireless/mwifiex/cmdevt.c              |  11 +-
 drivers/net/wireless/mwifiex/main.c                |   3 +-
 drivers/net/wireless/mwifiex/main.h                |   1 +
 drivers/net/wireless/mwifiex/pcie.c                |   7 +-
 drivers/net/wireless/mwifiex/scan.c                |  19 +-
 drivers/net/wireless/mwifiex/sdio.c                |   2 +
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   9 +-
 drivers/net/wireless/mwifiex/tdls.c                |   6 +-
 drivers/net/wireless/mwifiex/usb.c                 |   1 +
 drivers/net/wireless/rsi/rsi_91x_mgmt.c            |   3 +-
 drivers/net/wireless/rtl818x/Kconfig               |   4 +-
 drivers/net/wireless/rtl818x/rtl8180/Makefile      |   2 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c         | 691 +++++++++++++++++=
+---
 drivers/net/wireless/rtl818x/rtl8180/rtl8180.h     |  64 +-
 drivers/net/wireless/rtl818x/rtl8180/rtl8225.c     |   1 +
 drivers/net/wireless/rtl818x/rtl8180/rtl8225se.c   | 475 ++++++++++++++
 drivers/net/wireless/rtl818x/rtl8180/rtl8225se.h   |  61 ++
 drivers/net/wireless/rtl818x/rtl8187/dev.c         |   6 +-
 drivers/net/wireless/rtl818x/rtl818x.h             | 258 ++++++--
 drivers/net/wireless/rtlwifi/core.c                |   2 +-
 drivers/net/wireless/rtlwifi/pci.c                 |  69 +-
 drivers/net/wireless/rtlwifi/ps.c                  |  19 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c        |   5 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/fw.c        |   4 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        |  66 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c        |   1 +
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c       |   4 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |  14 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |  14 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c        |   5 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        |  67 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |   4 +-
 drivers/net/wireless/rtlwifi/rtl8723be/dm.c        |   2 +-
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c        |  64 +-
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c       |   4 +-
 .../net/wireless/rtlwifi/rtl8723com/fw_common.c    |   4 +-
 include/net/bluetooth/hci_core.h                   |   3 +-
 net/bluetooth/hci_event.c                          |  63 +-
 net/bluetooth/l2cap_sock.c                         |   3 +-
 net/bluetooth/mgmt.c                               |  20 +-
 net/bluetooth/rfcomm/sock.c                        |   3 +-
 net/bluetooth/smp.c                                |  87 ++-
 net/bluetooth/smp.h                                |   7 +-
 49 files changed, 1805 insertions(+), 395 deletions(-)
 create mode 100644 drivers/net/wireless/rtl818x/rtl8180/rtl8225se.c
 create mode 100644 drivers/net/wireless/rtl818x/rtl8180/rtl8225se.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--XsQoSWH+UP9D9v3l
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTOcKGAAoJEJctW/TcYTgGuiAP/0SZyKts4sc5BqIgXFLb7FtC
3meIeghoB/5QJM4fGXtTyL/0wXCH2lVi7Ajmb9AhdPjx3VwWg4kew0J9qr6psMow
DPuwwbpCWU1kdJJvFyiSlFJhuBnlpBP1N+TngEi5iDDmNdst7w5QSBrBIT3yTNk3
wcvoMsE7xpOERQPw8qwRPj8vxyhORKuRakObJXZ/0vwyGsgTAHU8fb4FoSU04jLj
wFKp+zPvjpJZCldX4io4OJSTgBHQLH5esxCRGW7rErpUwIww0AEskRs+Tnn7tbqV
/bmbUEKDt5ErpJPPySDP69RBffb+XPX43NFxsi6j1h6QpPqGLiIruA2hu3luHAN0
GDX76zPc81Hl/mYmYjCSZbCpH/QJcUhtA+8+7j6gIe0TT0xjRrMgBVbreYSrQ0dd
nwaKnLqyzZpHV8KRX1kHI7I54TtX3Z4zUw31MtNikGfWUrQstc6LYCdUL+gGZK+D
TYE8KZRrZ5kjGpVX5CIJLt/wx0+MGPLNhEW/ZKycQ84vIIA0WoW1AwI/5aNYyEbt
G2ANihgLXGptLf6TKGlkyDOROAu42P/YIp/G2bCkAyl54rK49RwyEazMvwkCGU00
VuCWj3yIQoamd9s32k8AvtyOW5ZAEnBEnRxrnW2obIqTuMATUw9iBHiqzGu3s0R6
QhU/9Tv9BuBsnm3epdeo
=Qt2G
-----END PGP SIGNATURE-----

--XsQoSWH+UP9D9v3l--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
