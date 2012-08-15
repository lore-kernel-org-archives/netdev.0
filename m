From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2012-08-15
Date: Wed, 15 Aug 2012 14:54:10 -0400
Message-ID: <20120815185409.GA2137@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="CE+1k2dSO48ffgeK"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45916 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273Ab2HOTE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2012 15:04:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 16698918cdb39ae0d9289741ac2a9ed179f8b8ba

Dave,

This is a batch of updates intended for 3.7.  The ath9k, mwifiex,
and b43 drivers get the bulk of the commits this time, with a handful
of other driver bits thrown-in.  It is mostly just minor fixes and
cleanups, etc.

Also included is a Bluetooth pull, with a lot of refactoring.
Gustavo says:

	"These are the changes I queued for 3.7. There are a many
	small fixes/improvements by Andre Guedes. A l2cap channel
	refcounting refactor by Jaganath. Bluetooth sockets now
	appears in /proc/net, by Masatake Yamato and Sachin Kamat
	changes ours drivers to use devm_kzalloc()."

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 1f07b62f3205f6ed41759df2892eaf433bc051a1:

  sctp: fix a compile error in sctp.h (2012-08-15 03:43:43 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 16698918cdb39ae0d9289741ac2a9ed179f8b8ba:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2012-08-15 14:29:37 -0400)

----------------------------------------------------------------

Amitkumar Karwar (4):
      mwifiex: do le_to_cpu conversion for Rx packet header elements
      mwifiex: update max_chan_per_scan correctly for SSID scan
      mwifiex: improve scan delay logic during Tx traffic
      mwifiex: notify cfg80211 about MIC failures

Andre Guedes (17):
      Bluetooth: Remove missing code
      Bluetooth: Use lmp_bredr_capable where applicable
      Bluetooth: Use lmp_le_capable where applicable
      Bluetooth: Use lmp_ssp_capable where applicable
      Bluetooth: Use lmp_esco_capable where applicable
      Bluetooth: Use lmp_rswitch_capable where applicable
      Bluetooth: Use lmp_sniff_capable where applicable
      Bluetooth: Use lmp_sniffsubr_capable where applicable
      Bluetooth: Use lmp_no_flush_capable where applicable
      Bluetooth: Remove locking in hci_user_passkey_request_evt
      Bluetooth: Trivial refactoring
      Bluetooth: Fix hci_le_conn_complete_evt
      Bluetooth: Remove unneeded code
      Bluetooth: Refactor hci_cs_le_create_conn
      Bluetooth: Find hci_conn by BT_CONNECT state
      Bluetooth: Lookup hci_conn in hci_le_conn_complete_evt
      Bluetooth: Refactor in hci_le_conn_complete_evt

Andrei Emeltchenko (8):
      Bluetooth: mgmt: Managing only BR/EDR HCI controllers
      Bluetooth: debug: Fix printing A2MP cmd code format
      Bluetooth: debug: Fix printing refcnt for hci_conn
      Bluetooth: trivial: Fix mixing spaces and tabs in smp
      Bluetooth: Define AMP controller statuses
      Bluetooth: Do not shadow hdr variable
      Bluetooth: Fix processing A2MP chan in security_cfm
      Bluetooth: Make connect / disconnect cfm functions return void

Avinash Patil (7):
      mwifiex: update 11n status as per start_ap IE
      mwifiex: separate file for handling AP events
      mwifiex: create list for associated stations in AP mode
      mwifiex: improve uAP RX handling
      mwifiex: support RX AMSDU aggregation for uAP
      mwifiex: add 11n Block Ack support for uAP
      mwifiex: cleanup TX/RX BA tables for uAP

Bing Zhao (2):
      mwifiex: fix powerpc64-linux- compilation warnings
      mwifiex: fix 'smatch' warning in preparing key_material cmd

Christian Lamparter (2):
      p54: parse output power table
      p54: fix powerpc gcc warnings

Dan Carpenter (1):
      mwifiex: use GFP_ATOMIC under spin lock

Fengguang Wu (1):
      mwifiex: fix code mis-alignment after the if statement

Gabor Juhos (2):
      ath9k: optimize power level initialization for CTL_[25]GHT20
      ath9k: fix indentation in ar9003_hw_set_power_per_rate_table

Hauke Mehrtens (1):
      bcma: make some functions static

Jaganath Kanakkassery (2):
      Bluetooth: Move l2cap_chan_hold/put to l2cap_core.c
      Bluetooth: Free the l2cap channel list only when refcount is zero

Javier Lopez (1):
      carl9170: Add support for NL80211_IFTYPE_MESH_POINT interfaces

Jeff Mahoney (1):
      brcmsmac: document firmware dependencies

Johannes Berg (2):
      brcmsmac: use ieee80211_channel_to_frequency
      iwlegacy: clean up suspend/resume

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth=
-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Larry Finger (1):
      p54pci: convert driver to use asynchronous firmware loading

Marco Porsch (1):
      mac80211: fix unnecessary beacon update after peering status change

Masatake YAMATO (8):
      Bluetooth: /proc/net/ entries for bluetooth protocols
      Bluetooth: Added /proc/net/bnep via bt_procfs_init()
      Bluetooth: Added /proc/net/cmtp via bt_procfs_init()
      Bluetooth: Added /proc/net/hci via bt_procfs_init()
      Bluetooth: Added /proc/net/hidp via bt_procfs_init()
      Bluetooth: Added /proc/net/l2cap via bt_procfs_init()
      Bluetooth: Added /proc/net/rfcomm via bt_procfs_init()
      Bluetooth: Added /proc/net/sco via bt_procfs_init()

Nick Kossifidis (4):
      ath5k: Use correct value for min_pwr and cur_pwr
      ath5k: Fix range scaling when setting rate power table
      ath5k: Preserve tx power level requested from above on phy_init
      ath5k: Put power_level where it belongs and rename it

Rafa=C5=82 Mi=C5=82ecki (12):
      b43: N-PHY: update workarounds
      b43: N-PHY: add PHY rev7+ workarounds
      b43: rename host flags defines
      b43: add helper waiting for given value in radio reg
      b43: N-PHY: finish 0x2056 radio setup
      b43: N-PHY: init 0x2057 radio
      b43: be more user friendly with PHY info
      b43: N-PHY: add overriding RF control for rev7+
      bcma: add (mostly) NAND defines
      b43: N-PHY: fix 0x2057 radio calib copy/paste mistake
      b43legacy: fix logic in GPIO init
      ssb: check for flash presentence

Rajkumar Manoharan (1):
      ath9k: tune rc_stats to display only valid rates

Sachin Kamat (11):
      Bluetooth: Use devm_kzalloc in bcm203x.c file.
      Bluetooth: Use devm_kzalloc in bfusb.c file
      Bluetooth: Use devm_kzalloc in bluecard_cs.c file
      Bluetooth: Use devm_kzalloc in bpa10x.c file
      Bluetooth: Use devm_kzalloc in bt3c_cs.c file
      Bluetooth: Use devm_kzalloc in btmrvl_sdio.c file
      Bluetooth: Use devm_kzalloc in btsdio.c file
      Bluetooth: Use devm_kzalloc in btuart_cs.c file
      Bluetooth: Use devm_kzalloc in btusb.c file
      Bluetooth: Use devm_kzalloc in btwilink.c file
      Bluetooth: Use devm_kzalloc in dtl1_cs.c file

Sujith Manoharan (14):
      ath9k: Simplify rate table initialization
      ath9k: Cleanup RC init API
      ath9k: Cleanup ath_rc_setvalid_rates
      ath9k: Cleanup ath_rc_setvalid_htrates
      ath9k: Cleanup index retrieval routines
      ath9k: Change rateset calculation
      ath9k: Remove ath_rc_set_valid_rate_idx
      ath9k: Unify valid rate calculation routines
      ath9k: Do not set IEEE80211_TX_RC_USE_SHORT_PREAMBLE
      ath9k: Fix RTS/CTS rate selection
      ath9k: Bail out properly before calculating rate index
      ath9k: Cleanup TX status API
      ath9k: Remove MIMO-PS specific code
      ath9k: Trim rate table

Ying Luo (3):
      mwifiex: rename wapi_rxpn to pn
      mwifiex: pass key_params pointer in mwifiex_set_encode
      mwifiex: add AES_CMAC support in key_material cmd

Yogesh Ashok Powar (3):
      mwifiex: copy MSDU subframes correctly
      mwifiex: remove extra padding to AMSDU
      mwifiex: correction in MSDU padding logic

 drivers/bcma/driver_chipcommon_pmu.c               |   4 +-
 drivers/bcma/host_pci.c                            |  11 +-
 drivers/bcma/host_soc.c                            |   2 +-
 drivers/bluetooth/bcm203x.c                        |   8 +-
 drivers/bluetooth/bfusb.c                          |  12 +-
 drivers/bluetooth/bluecard_cs.c                    |   5 +-
 drivers/bluetooth/bpa10x.c                         |   8 +-
 drivers/bluetooth/bt3c_cs.c                        |   5 +-
 drivers/bluetooth/btmrvl_sdio.c                    |  15 +-
 drivers/bluetooth/btsdio.c                         |   8 +-
 drivers/bluetooth/btuart_cs.c                      |   5 +-
 drivers/bluetooth/btusb.c                          |  13 +-
 drivers/bluetooth/btwilink.c                       |   8 +-
 drivers/bluetooth/dtl1_cs.c                        |   3 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |   2 +-
 drivers/net/wireless/ath/ath5k/base.c              |   5 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |   4 +-
 drivers/net/wireless/ath/ath5k/phy.c               |  43 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     | 149 ++--
 drivers/net/wireless/ath/ath9k/rc.c                | 812 +++++++++--------=
----
 drivers/net/wireless/ath/ath9k/rc.h                |   4 -
 drivers/net/wireless/ath/carl9170/fw.c             |   1 +
 drivers/net/wireless/ath/carl9170/mac.c            |   2 +-
 drivers/net/wireless/ath/carl9170/main.c           |   4 +-
 drivers/net/wireless/ath/carl9170/rx.c             |   1 +
 drivers/net/wireless/b43/Makefile                  |   1 +
 drivers/net/wireless/b43/b43.h                     |  10 +-
 drivers/net/wireless/b43/main.c                    |  51 +-
 drivers/net/wireless/b43/phy_common.c              |  17 +-
 drivers/net/wireless/b43/phy_common.h              |   6 +
 drivers/net/wireless/b43/phy_n.c                   | 668 ++++++++++++++++-
 drivers/net/wireless/b43/phy_n.h                   |   1 +
 drivers/net/wireless/b43/radio_2057.c              | 141 ++++
 drivers/net/wireless/b43/radio_2057.h              | 430 +++++++++++
 drivers/net/wireless/b43/tables_nphy.c             |  75 ++
 drivers/net/wireless/b43/tables_nphy.h             |  10 +
 drivers/net/wireless/b43legacy/main.c              |   2 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   4 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |  13 +-
 .../net/wireless/brcm80211/include/brcmu_wifi.h    |   5 -
 drivers/net/wireless/iwlegacy/common.c             |  15 +-
 drivers/net/wireless/iwlegacy/common.h             |   2 -
 drivers/net/wireless/mwifiex/11n.c                 |  26 +
 drivers/net/wireless/mwifiex/11n.h                 |  15 +
 drivers/net/wireless/mwifiex/11n_aggr.c            |  14 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |  66 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.h       |   5 +
 drivers/net/wireless/mwifiex/Makefile              |   2 +
 drivers/net/wireless/mwifiex/cfg80211.c            |  17 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |   5 +-
 drivers/net/wireless/mwifiex/decl.h                |   3 +
 drivers/net/wireless/mwifiex/fw.h                  |  42 +-
 drivers/net/wireless/mwifiex/init.c                | 107 +--
 drivers/net/wireless/mwifiex/ioctl.h               |   5 +-
 drivers/net/wireless/mwifiex/main.c                |   3 +
 drivers/net/wireless/mwifiex/main.h                |  38 +-
 drivers/net/wireless/mwifiex/scan.c                |   6 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |  55 +-
 drivers/net/wireless/mwifiex/sta_event.c           |  64 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |  12 +-
 drivers/net/wireless/mwifiex/sta_rx.c              |  38 +-
 drivers/net/wireless/mwifiex/txrx.c                |   5 +
 drivers/net/wireless/mwifiex/uap_cmd.c             |   1 +
 drivers/net/wireless/mwifiex/uap_event.c           | 290 ++++++++
 drivers/net/wireless/mwifiex/uap_txrx.c            | 255 +++++++
 drivers/net/wireless/mwifiex/wmm.c                 |  59 +-
 drivers/net/wireless/p54/eeprom.c                  | 108 ++-
 drivers/net/wireless/p54/eeprom.h                  |  12 +
 drivers/net/wireless/p54/p54pci.c                  |  88 ++-
 drivers/net/wireless/p54/p54pci.h                  |   1 +
 drivers/ssb/driver_mipscore.c                      |  28 +-
 include/linux/bcma/bcma_driver_chipcommon.h        |  85 +++
 include/linux/bcma/bcma_regs.h                     |   2 +
 include/linux/ssb/ssb_driver_chipcommon.h          |   4 +-
 include/net/bluetooth/bluetooth.h                  |  10 +
 include/net/bluetooth/hci.h                        |  11 +
 include/net/bluetooth/hci_core.h                   |  22 +-
 include/net/bluetooth/l2cap.h                      |  17 +-
 include/net/bluetooth/smp.h                        |   8 +-
 net/bluetooth/a2mp.c                               |  16 +-
 net/bluetooth/af_bluetooth.c                       | 141 ++++
 net/bluetooth/bnep/sock.c                          |  22 +-
 net/bluetooth/cmtp/sock.c                          |  23 +-
 net/bluetooth/hci_core.c                           |   6 +-
 net/bluetooth/hci_event.c                          |  93 +--
 net/bluetooth/hci_sock.c                           |  13 +-
 net/bluetooth/hidp/sock.c                          |  22 +-
 net/bluetooth/l2cap_core.c                         |  32 +-
 net/bluetooth/l2cap_sock.c                         |  22 +-
 net/bluetooth/mgmt.c                               |  34 +-
 net/bluetooth/rfcomm/sock.c                        |  14 +-
 net/bluetooth/sco.c                                |  16 +-
 net/mac80211/mesh.c                                |  21 +-
 net/mac80211/mesh.h                                |   2 +-
 net/mac80211/mesh_plink.c                          |  44 +-
 95 files changed, 3509 insertions(+), 1126 deletions(-)
 create mode 100644 drivers/net/wireless/b43/radio_2057.c
 create mode 100644 drivers/net/wireless/b43/radio_2057.h
 create mode 100644 drivers/net/wireless/mwifiex/uap_event.c
 create mode 100644 drivers/net/wireless/mwifiex/uap_txrx.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--CE+1k2dSO48ffgeK
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIbBAEBAgAGBQJQK/BRAAoJEJctW/TcYTgG60QP9i9/EzKaL4Fjr8/uF3LLX/A8
hVPscqOnR/bWBaG4/2tWbavTS+KpQCj1bCEmp8rwvPN0Sx/JTpB8hS7lwd8oh2Pn
XlUqIHuQrkrqeJzIZsyPL7LsECP3aujgEFDjJWiqMu+0uAgZv3LBhp3yizS+l59V
xHePdQeOnwYei3Wo9WCHGuxrZPTglVpGlbPIPJys1lgQ+sQIF8K2+vlFbPQkzMA2
OBPraWFkBS0Ac1rqYk+QRAp2bKcvgChBJ6Kr+uky4B1vmJmpXgwyGSF1nfFDKAim
8yjdmLUOJZNXCbmBS9nCI0dEJMWHmRficjSuBqwzUx4+TcQr4tY716EJYS8i1CKa
okqALVEgP4SH5YLSUY9fggx44LvrHrjeC/wsjl+KUQ09rBK+bQALMrBxO4Paf74h
990Gb0BHRaej3rFV7BYnQY/Aod0wsW6HlbOfQQszH4opifualZXlubK9Ymr1rqyL
idpXcOyfsLGrSk9UlgGy97iOOgC/IeTvIHhs/jaI15MOWXlCRtk2BD1GC05m3Ai+
qVsaezBgGKMsRu9iHSAfvOCjmv4/0sAVROuySx5boTMF+pr2zpDz/ahp9yUjdvON
cL1hrqpZLoOkOnbIJbPWznI+F3UTcLrIgNmt3T4fOvatSQY7xhEsjfqyGoeLhMrd
sfima6reklPluq897IQ=
=qPjN
-----END PGP SIGNATURE-----

--CE+1k2dSO48ffgeK--
