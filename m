From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2014-06-02
Date: Mon, 2 Jun 2014 13:09:14 -0400
Message-ID: <20140602170914.GA13192@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FCuugMFkClbJLl1L"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this remaining batch of updates intended for the 3.16 stream...

For the mac80211 bits, Johannes says:

"The remainder for -next right now is mostly fixes, and a handful of
small new things like some CSA infrastructure, the regdb script mW/dBm
conversion change and sending wiphy notifications."

For the bluetooth bits, Gustavo says:

"Some more patches for 3.16. There is nothing really special here, just a
bunch of clean ups, fixes plus some small improvements. Please pull."

For the nfc bits, Samuel says:

"We have:

- Felica (Type3) tags support for trf7970a
- Type 4b tags support for port100
- st21nfca DTS typo fix
- A few sparse warning fixes"

For the atheros bits, Kalle says:

"Ben added support for setting antenna configurations. Michal improved
warm reset so that we would not need to fall back to cold reset that
often, an issue where ath10k stripped protected flag while in monitor
mode and made module initialisation asynchronous to fix the problems
with firmware loading when the driver is linked to the kernel.

Luca removed unused channel_switch_beacon callbacks both from ath9k and
ath10k. Marek fixed Protected Management Frames (PMF) when using Action
Frames. Also we had other small fixes everywhere in the driver."

Along with that, there are a handful of updates to a variety
of drivers.  This includes updates to at76c50x-usb, ath9k, b43,
brcmfmac, mwifiex, rsi, rtlwifi, and wil6210.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 96b2e73c5471542cb9c622c4360716684f8797ed:

  Revert "net/mlx4_en: Use affinity hint" (2014-06-02 00:18:48 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to fcb2c0d6cf75750e2912b09a3d0a782c90e2b1a0:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2014-06-02 11:20:17 -0400)

----------------------------------------------------------------

Andrea Merello (2):
      at76c50x-usb: Don't perform DMA from stack memory
      at76c50x-usb: Make WEP encryption working.

Andrzej Kaczmarek (8):
      Bluetooth: Store RSSI for connection
      Bluetooth: Store TX power level for connection
      Bluetooth: Add conn info lifetime parameters to debugfs
      Bluetooth: Add support to get connection information
      Bluetooth: Avoid polling TX power for LE links
      Bluetooth: Store max TX power level for connection
      Bluetooth: Add support for max_tx_power in Get Conn Info
      Bluetooth: Add missing msecs to jiffies conversion

Arend van Spriel (13):
      brcmfmac: reduce log level for invalid scheduled scan request
      brcmfmac: restore mpc before passing scan status to cfg80211
      brcmfmac: make chandef_to_chanspec() function static
      brcmfmac: remove .init() callback for internal bus interface
      brcmfmac: rename nvram.[ch] for upcoming firmware handling functions
      brcmfmac: call brcmf_detach() unconditional in sdio .remove() callback
      brcmfmac: rework usb callback operations
      brcmfmac: introduce asynchronous firmware loading
      brcmfmac: use asynchronous firmware request in SDIO
      brcmfmac: use asynchronous firmware request in USB
      brcmfmac: make brcmf_fw_nvram_strip() static
      brcmutil: assure unused bits are cleared in 11n chanspec
      brcmfmac: remove firmware list from USB driver

Arik Nemtsov (1):
      mac80211: don't check netdev state for debugfs read/write

Avinash Patil (2):
      mwifiex: fix a crash in extended scan event processing
      mwifiex: set TDLS link for newly created RA list

Avraham Stern (1):
      mac80211: set new interfaces as idle upon init

Bartosz Markowski (1):
      ath10k: get rid of pci_assign_resource() call from pci_probe

Ben Greear (3):
      ath10k: fix spelling mistake in comments
      ath10k: support get/set antenna configurations.
      ath10k: ensure rx-frag ignores rssi

Benoit Taine (1):
      wcn36xx: Use kmemdup instead of kmalloc + memcpy

Bing Zhao (1):
      mwifiex: change hscfg gap parameter to avoid potential firmware deadl=
ock

Christophe Ricard (1):
      NFC: dts: st21nfca_i2c: Correct minor typo in documentation

Daniel Kim (1):
      brcmfmac: Increase max buffer size for receiving control message from=
 dongle

Emmanuel Grumbach (1):
      mac80211: fix virtual monitor interface addition

Felix Fietkau (3):
      mac80211: fix a memory leak on sta rate selection table
      mac80211: reduce packet loss notifications under load
      ath9k: avoid passing buffers to the hardware during flush

Fengguang Wu (2):
      NFC: digital: digital_in_send_attrib_req() can be static
      NFC: nfc_sock_link() can be static

Frederic Danis (1):
      ath10k: fix ath10k_bmi_read32 macro

Hante Meuleman (2):
      brcmfmac: Add log of superspeed device detection to USB probe.
      brcmfmac: Remove interrupt endpoint usage from USB driver.

Jes Sorensen (1):
      wireless: add missing WLAN_EID_BSS_INTOLERANT_CHL_REPORT

Johan Hedberg (8):
      Bluetooth: Add support for SMP Invalid Parameters error code
      Bluetooth: Make SMP context private to smp.c
      Bluetooth: Fix setting initial local auth_req value
      Bluetooth: Remove unnecessary work structs from SMP code
      Bluetooth: Rename smp->smp_flags to smp->flags
      Bluetooth: Update smp_random to return a response code
      Bluetooth: Update smp_confirm to return a response code
      Bluetooth: Clearly distinguish mgmt LTK type from authenticated prope=
rty

Johannes Berg (1):
      cfg80211: send events when devices are added/removed

John W. Linville (5):
      Merge git://git.kernel.org/.../jberg/mac80211-next
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge tag 'nfc-next-3.16-2' of git://git.kernel.org/.../sameo/nfc-next
      Merge branch 'for-linville' of git://github.com/kvalo/ath
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Kalle Valo (1):
      Merge remote-tracking branch 'wireless-next/master' into ath-next

Kees Cook (1):
      rsi: avoid format string leak to thread name

Krzysztof Ha=C5=82asa (1):
      mac80211: fix IBSS join by initializing last_scan_completed

Libor Pechacek (1):
      Bluetooth: Convert RFCOMM spinlocks into mutexes

Luciano Coelho (2):
      ath9k/ath10k: remove unnecessary channel_switch_beacon callbacks
      mac80211: add a single-transaction driver op to switch contexts

Manuel Sch=C3=B6lling (1):
      mwifiex: use time_after()

Marcel Holtmann (1):
      Bluetooth: Increment management interface revision

Marek Kwaczynski (1):
      ath10k: fix pmf for action frames

Mark A. Greer (1):
      NFC: trf7970a: Add support for Felica Type 3 tags

Michal Kazior (18):
      ath10k: fix htt rx ring clean up
      ath10k: fix handling of wierd MSDU chaining cases
      ath10k: improve warm reset reliability
      ath10k: retry warm reset a few times
      ath10k: enable early device dumps
      ath10k: fix core start sequence
      ath10k: prevent hif_stop being called twice
      ath10k: fix protected flag stripping
      ath10k: relocate core create/destroy functions
      ath10k: remove unnecessary tasklet_kill()
      ath10k: make core registering async
      ath10k: clean up start() callback
      ath10k: perform hw restart lazily
      ath10k: drain tx before restarting hw
      ath10k: protect wep tx key setup
      ath10k: dont configure bssid for ap mode
      ath10k: protect src_ring state with ce_lock in tx_sg()
      ath10k: abort incomplete scatter-gather pci tx properly

Paul Bolle (1):
      rtlwifi: rtl8192cu: remove check for CONFIG_AUTOSUSPEND

Petri Gynther (1):
      Bluetooth: btusb: Add Broadcom patch RAM support

Rafa=C5=82 Mi=C5=82ecki (3):
      b43: PHY: allow init optimizations by tracking PHY state
      b43: N-PHY: optimize init by doing some ops just once
      b43: N-PHY: optimize radio switching on/off

Rajkumar Manoharan (2):
      ath9k: Fix deadlock while updating p2p beacon timer
      ath9k: Fix interface combinations for multi-channel concurrency

Sachin Kamat (2):
      rtlwifi: rtl8723be: Remove duplicate inclusion of phy.h
      rtlwifi: rtl8723ae: Remove duplicate inclusion of fw_common.h

Thierry Escande (3):
      NFC: port100: Add support for type 4B tag
      NFC: digital: Return proper error code when sending ATR_REQ
      NFC: digital: Randomize poll cycles

Vladimir Kondratiev (7):
      wil6210: limit MTU
      wil6210: limit fw error recovery attempts
      wil6210: inline functions for vring hi/lo watermarks
      wil6210: detect scan timeouts
      wil6210: improve pointers printing
      wil6210: optimize wil_release_reorder_frames
      wil6210: improve debug for WMI receive

Zefir Kurtisi (1):
      ath9k: simplify DFS pulse interval debug printing

chaitanya.mgit@gmail.com (1):
      regdb: Generalize the mW to dBm power conversion

 .../devicetree/bindings/net/nfc/st21nfca.txt       |   2 +-
 drivers/bluetooth/btusb.c                          | 155 ++++++++++-
 drivers/net/wireless/at76c50x-usb.c                | 127 ++++++---
 drivers/net/wireless/at76c50x-usb.h                |  25 +-
 drivers/net/wireless/ath/ath10k/bmi.h              |   3 +-
 drivers/net/wireless/ath/ath10k/ce.c               |  27 ++
 drivers/net/wireless/ath/ath10k/ce.h               |   2 +
 drivers/net/wireless/ath/ath10k/core.c             | 277 +++++++++++------=
---
 drivers/net/wireless/ath/ath10k/core.h             |   8 +
 drivers/net/wireless/ath/ath10k/htc.c              |   6 -
 drivers/net/wireless/ath/ath10k/htt.c              |  42 +--
 drivers/net/wireless/ath/ath10k/htt.h              |  18 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |  92 +++++--
 drivers/net/wireless/ath/ath10k/htt_tx.c           |   8 +-
 drivers/net/wireless/ath/ath10k/mac.c              | 212 +++++++++++----
 drivers/net/wireless/ath/ath10k/pci.c              | 103 +++++---
 drivers/net/wireless/ath/ath10k/wmi.c              |  26 +-
 drivers/net/wireless/ath/ath10k/wmi.h              |   6 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   1 +
 drivers/net/wireless/ath/ath9k/dfs.c               |   6 +-
 drivers/net/wireless/ath/ath9k/dfs_debug.h         |   1 -
 drivers/net/wireless/ath/ath9k/init.c              |  25 +-
 drivers/net/wireless/ath/ath9k/main.c              |  27 +-
 drivers/net/wireless/ath/ath9k/recv.c              |  24 +-
 drivers/net/wireless/ath/wcn36xx/smd.c             |   3 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |   1 +
 drivers/net/wireless/ath/wil6210/debugfs.c         |   4 +-
 drivers/net/wireless/ath/wil6210/main.c            |  35 ++-
 drivers/net/wireless/ath/wil6210/netdev.c          |  14 +
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |   2 +-
 drivers/net/wireless/ath/wil6210/rx_reorder.c      |   9 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |  28 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |   6 +
 drivers/net/wireless/ath/wil6210/wmi.c             |  25 +-
 drivers/net/wireless/b43/main.c                    |   7 +-
 drivers/net/wireless/b43/phy_common.c              |   5 +
 drivers/net/wireless/b43/phy_common.h              |   3 +
 drivers/net/wireless/b43/phy_n.c                   |  17 +-
 drivers/net/wireless/b43/phy_n.h                   |   1 -
 drivers/net/wireless/b43/tables_nphy.c             |  80 +++---
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   |   2 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |   6 -
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |   7 -
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c | 283 ++++++++++-------=
----
 .../brcm80211/brcmfmac/{nvram.c =3D> firmware.c}     | 112 +++++++-
 .../brcm80211/brcmfmac/{nvram.h =3D> firmware.h}     |  24 +-
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      | 269 +++++++----------=
---
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |  11 +-
 drivers/net/wireless/brcm80211/brcmutil/d11.c      |   2 +-
 drivers/net/wireless/mwifiex/fw.h                  |   2 +-
 drivers/net/wireless/mwifiex/main.h                |   2 +-
 drivers/net/wireless/mwifiex/scan.c                |  29 ++-
 drivers/net/wireless/mwifiex/wmm.c                 |   1 +
 drivers/net/wireless/rsi/rsi_common.h              |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |   3 -
 .../wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c    |   1 -
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c       |   1 -
 drivers/nfc/port100.c                              |  36 ++-
 drivers/nfc/trf7970a.c                             |  13 +-
 include/linux/ieee80211.h                          |   1 +
 include/net/bluetooth/hci.h                        |  21 ++
 include/net/bluetooth/hci_core.h                   |  11 +
 include/net/bluetooth/mgmt.h                       |  15 ++
 include/net/bluetooth/rfcomm.h                     |   6 +-
 include/net/mac80211.h                             |  46 ++++
 net/bluetooth/hci_conn.c                           |   3 +
 net/bluetooth/hci_core.c                           |  64 +++++
 net/bluetooth/hci_event.c                          |  61 +++++
 net/bluetooth/mgmt.c                               | 236 ++++++++++++++++-
 net/bluetooth/rfcomm/core.c                        |   2 +-
 net/bluetooth/rfcomm/tty.c                         |  20 +-
 net/bluetooth/smp.c                                | 153 +++++------
 net/bluetooth/smp.h                                |  30 +--
 net/mac80211/debugfs_netdev.c                      |   6 +-
 net/mac80211/driver-ops.h                          |  53 ++++
 net/mac80211/ibss.c                                |   1 +
 net/mac80211/iface.c                               |   2 +
 net/mac80211/sta_info.c                            |   1 +
 net/mac80211/status.c                              |  25 +-
 net/mac80211/trace.h                               |  85 +++++++
 net/nfc/digital_core.c                             |   6 +-
 net/nfc/digital_dep.c                              |   5 +-
 net/nfc/digital_technology.c                       |   2 +-
 net/nfc/rawsock.c                                  |   4 +-
 net/wireless/core.c                                |   5 +-
 net/wireless/genregdb.awk                          |  14 +-
 net/wireless/nl80211.c                             |  21 +-
 net/wireless/nl80211.h                             |   3 +-
 88 files changed, 2174 insertions(+), 997 deletions(-)
 rename drivers/net/wireless/brcm80211/brcmfmac/{nvram.c =3D> firmware.c} (=
65%)
 rename drivers/net/wireless/brcm80211/brcmfmac/{nvram.h =3D> firmware.h} (=
52%)
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--FCuugMFkClbJLl1L
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTjK+6AAoJEJctW/TcYTgGDz8P/3kt1mymXuIXhbMOtkctoFKA
Ppsppk8QIrs//4ngtYx5WyxfDyHsxLK7ZOFrfcusnGJ10qDXFonWnV4ZDTUXihH9
gofU8XOpBZ3YDpGKCnUTL7XS9Ckx6B7vfv63pJkrj7pkSEzfm+tVZvV/ywKx02k/
Rf1TLymy5NP7rXyfzjwLz6eOg2DLnuMbdIVqOdlLkFVMO4Cr9PVP8VPRy2AMnlQG
8/2E4TItfriWMm8RDPUCheGQZF0nZF26bNAWNZqQS/o2GRfO/ocVcfl2d4MdiI7C
XxPWuZ3oGCbDc3AeK4OhiLSGXoSxW+P6+/3i9RERQPu04+y14/bl3cFXFlAZ7Cx4
Fc302+kj+x3f8z6sQ1DmIg/l4wNPKq39js+FSP1mFsX0RiqWgqkNXbiDdtFApw7S
3GDL5r/YWHqUIV4jVrts6aWbCtRWF8B6FH/xGPEh1/foNnA2TbEA/ZLbn2r7wIIu
eaTakJNzol0AEig/8+UYy9gcvvoPnSbomYFq6QIwjNdhu7KDoYfYG6oR29KghM40
LyG8DlReahD93bJYwexQuB2mW0BTQB+0/ZbV+YFh+O1qkQ2r0bIDDAN3kOi32ps/
7Y5jz7PLpdYCYzpeRtiy1UANSAEJupQ5T3U/AdVbDb4Xxd568nRP+IDWLo/Bv4m9
2wgO9kwbMG7dBME7D08A
=W0vt
-----END PGP SIGNATURE-----

--FCuugMFkClbJLl1L--
