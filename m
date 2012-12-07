From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2012-12-07
Date: Fri, 7 Dec 2012 13:57:54 -0500
Message-ID: <20121207185754.GF1869@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="liOOAslEiF7prFVr"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42350 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844Ab2LGTBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 14:01:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--liOOAslEiF7prFVr
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

This pull request is intended for 3.8...

This includes a Bluetooth pull.  Gustavo says:

"A few more patches to 3.8, I hope they can still make it to mainline!
The most important ones are the socket option for the SCO protocol to allow
accept/refuse new connections from userspace. Other than that I added some
fixes and Andrei did more AMP work."

Also, a mac80211 pull.  Johannes says:

"If you think there's any chance this might make it still, please pull my
mac80211-next tree (per below). This contains a relatively large number
of fixes to the previous code, as well as a few small features:
 * VHT association in mac80211
 * some new debugfs files
 * P2P GO powersave configuration
 * masked MAC address verification

The biggest patch is probably the BSS struct changes to use RCU for
their IE buffers to fix potential races. I've not tagged this for stable
because it's pretty invasive and nobody has ever seen any bugs in this
area as far as I know."

Several other drivers get some attention, including ath9k, brcmfmac,
brcmsmac, and a number of others.  Also, Hauke gives us a series that
improves watchdog support for the bcma and ssb busses.  Finally, Bill
Pemberton delivers a group of "remove __dev* attributes" for wireless
drivers -- these generate some "section mismatch" warnings, but Greg
K-H assures me that they will disappear by the time -rc1 is released.

This also includes a pull of the wireless tree to avoid merge
conflicts.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit fd3065b25b69ce345073bbd294a73343a608fd8b:

  chelsio: remove get_clock and use ktime_get (2012-12-07 12:56:22 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 8024dc191025d6b981563236df02da5c0db0854d:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2012-12-07 13:03:50 -0500)

----------------------------------------------------------------

Andrei Emeltchenko (6):
      Bluetooth: Refactor l2cap_send_disconn_req
      Bluetooth: AMP: Mark controller radio powered down after HCIDEVDOWN
      Bluetooth: AMP: Check that AMP is present and active
      Bluetooth: Fix missing L2CAP EWS Conf parameter
      Bluetooth: Process receiving FCS_NONE in L2CAP Conf Rsp
      Bluetooth: trivial: Change NO_FCS_RECV to RECV_NO_FCS

Antonio Quartulli (1):
      mac80211: allow userspace registration for probe requests in IBSS

Arend van Spriel (3):
      brcm80211: update the MAINTAINERS file
      brcmfmac: get rid of struct brcmf_cfg80211_info::link_up attribute
      brcmfmac: remove mode from struct brcmf_cfg80211_conf

Avinash Patil (1):
      mwifiex: advertise GreenField, 40MHz intolerance support to cfg80211

Bill Pemberton (18):
      rfkill: remove __dev* attributes
      wireless: remove __dev* attributes
      ath5k: remove __dev* attributes
      atmel: remove __dev* attributes
      b43: remove __dev* attributes
      brcm80211: remove __dev* attributes
      ipw2x00: remove __dev* attributes
      iwlegacy: remove __dev* attributes
      iwlwifi: remove __dev* attributes
      libertas: remove __dev* attributes
      mwl8k: remove __dev* attributes
      orinoco: remove __dev* attributes
      p54: remove __dev* attributes
      rt2x00: remove __dev* attributes
      rtl8187: remove __dev* attributes
      rtl8187: remove __dev* attributes
      wlcore/wl18xx/wl12xx: remove __dev* attributes
      rtlwifi: remove __dev* attributes

Christian Lamparter (2):
      carl9170: fix signal strength reporting issues
      carl9170: explain why sta cannot be NULL for ampdus

Dan Carpenter (2):
      mac80211: fix potential NULL dereference
      p54: potential signedness issue in p54_parse_rssical()

Daniel Stamer (1):
      rtlwifi: rtl8192se: Fixed coding style issues in the driver

Emmanuel Grumbach (1):
      iwlwifi: fix the basic CCK rates calculation

Florian Fainelli (1):
      mwl8k: remove useless pci shutdown callback and stray debugging

Fr=E9d=E9ric Dalleau (2):
      Bluetooth: Add BT_DEFER_SETUP option to sco socket
      Bluetooth: Implement deferred sco socket setup

Gabor Juhos (4):
      rt2x00: rt2800lib: fix indentation of some rt2x00_rt calls
      rt2x00: rt2800lib: fix indentation in rt2800_init_rfcsr
      rt2x00: rt2800lib: remove trailing semicolons from RFCSR3_* defines
      rt2x00: rt2800lib: introduce RFCSR3_VCOCAL_EN

Gustavo Padovan (4):
      Bluetooth: Add missing lock nesting notation
      Bluetooth: cancel power_on work when unregistering the device
      Bluetooth: Move double negation to macros
      Revert "Bluetooth: Fix possible deadlock in SCO code"

Hante Meuleman (2):
      brcmfmac: fix bug in setting mgmt ie and parsing vndrs ie.
      brcmfmac: change debug output for received event.

Hauke Mehrtens (16):
      bcma: handle return value of pci_assign_resource
      ssb: extif: fix compile errors
      ath9k: use SIMPLE_DEV_PM_OPS
      p54pci: use SIMPLE_DEV_PM_OPS
      rtlwifi: use SIMPLE_DEV_PM_OPS
      ssb/bcma: add common header for watchdog
      bcma: add bcma_chipco_alp_clock
      bcma: set the pmu watchdog if available
      bcma: add methods for watchdog driver
      bcma: register watchdog driver
      ssb: get alp clock from devices with PMU
      ssb: set the PMU watchdog if available
      ssb: add methods for watchdog driver
      ssb: extif: add check for max value before setting watchdog register
      ssb: extif: add methods for watchdog driver
      ssb: register watchdog driver

Helmut Schaa (4):
      mac80211: reject setting masked mac addresses
      mac80211: don't reinit rate control when mesh sta exists
      rt2x00: Use addr_mask to disallow invalid MAC addresses in mutli-bssi=
d mode
      rt2x00: Only specify interface combinations if more then one interfac=
e is possible

Johannes Berg (15):
      mac80211: fix remain-on-channel (non-)cancelling
      cfg80211: rework chandef checking and export it
      mac80211: support VHT association
      mac80211: support (partial) VHT radiotap information
      nl80211: support P2P GO powersave configuration
      mac80211: support P2P GO powersave configuration
      nl80211: remove unnecessary checks
      cfg80211: don't BUG_ON BSS struct issues
      cfg80211: fix whitespace in scan handling
      cfg80211: fix cmp_hidden_bss
      mac80211: make ieee80211_build_preq_ies safer
      mac80211: remove probe response temporary buffer allocation
      cfg80211: fix BSS struct IE access races
      mac80211: simplify loop in minstrel_ht
      mwifiex: fix struct member mismatch

John W. Linville (5):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge tag 'nfc-fixes-3.7-2' of git://git.kernel.org/.../sameo/nfc-3.0
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Luis R. Rodriguez (1):
      brcmfmac: convert struct spinlock to spinlock_t

Mahesh Palivela (1):
      cfg80211: Remove unused VHT chan code

Marco Porsch (2):
      mac80211: fix for mesh sync to indicate TBTT adjustment
      cfg80211: fix channel error on mesh join

Masanari Iida (1):
      wireless: mwifiex: Fix typo in wireless/mwifiex driver

Piotr Haber (6):
      brcmsmac: handle packet drop during transmit correctly
      brcmsmac: cleanup in isr code
      brcmsmac: fix bounds checking in tx/rx
      brcmsmac: hardware info in debugfs
      brcmsmac: move PHY functions
      brcmsmac: support 4313iPA

Rajkumar Manoharan (1):
      ath9k: Fix buffer overflow error

Saravana (4):
      mac80211: add debugfs file for last ack signal
      mac80211: add debugfs file for current tx rate
      mac80211: re-organize the rx rate calculation logic
      mac80211: add debugfs file for last rx rate

Seth Forshee (1):
      brcmsmac: Fix possible NULL pointer dereference in _dma_ctrlflags()

Simon Wunderlich (3):
      nl80211: Fix HT_IBSS feature check in ibss_join
      mac80211: Fix typo in mac80211.h
      mac80211: return if CSA is not handle

Sujith Manoharan (4):
      ath9k: Move ethtool functions to debug.c
      ath9k: Replace WME_NUM_TID with IEEE80211_NUM_TIDS
      ath9k: Implement sta_add_debugfs/sta_remove_debugfs
      ath9k: Remove redundant NULL assignment

Vladimir Kondratiev (1):
      wireless: allow Atheros card to not depend on ath.ko

Waldemar Rymarkiewicz (1):
      NFC: Fix incorrect llcp pointer dereference

Wei Yongjun (2):
      brcmsmac: remove duplicated include from debug.c
      ipw2200: return error code on error in ipw_wx_get_auth()

 MAINTAINERS                                        |   3 +-
 drivers/bcma/bcma_private.h                        |   2 +
 drivers/bcma/driver_chipcommon.c                   | 114 ++++-
 drivers/bcma/driver_pci_host.c                     |  10 +-
 drivers/bcma/main.c                                |   8 +
 drivers/net/wireless/adm8211.c                     |   6 +-
 drivers/net/wireless/airo.c                        |   6 +-
 drivers/net/wireless/ath/Kconfig                   |   7 +-
 drivers/net/wireless/ath/ar5523/Kconfig            |   1 +
 drivers/net/wireless/ath/ath5k/Kconfig             |   1 +
 drivers/net/wireless/ath/ath5k/base.c              |   4 +-
 drivers/net/wireless/ath/ath5k/led.c               |   2 +-
 drivers/net/wireless/ath/ath5k/pci.c               |   6 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |   1 +
 drivers/net/wireless/ath/ath9k/ath9k.h             |   7 +-
 drivers/net/wireless/ath/ath9k/common.h            |   1 -
 drivers/net/wireless/ath/ath9k/debug.c             | 209 +++++++++
 drivers/net/wireless/ath/ath9k/debug.h             |  17 +-
 drivers/net/wireless/ath/ath9k/main.c              | 137 +-----
 drivers/net/wireless/ath/ath9k/mci.c               |   3 +-
 drivers/net/wireless/ath/ath9k/pci.c               |  15 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |   9 +-
 drivers/net/wireless/ath/carl9170/Kconfig          |   1 +
 drivers/net/wireless/ath/carl9170/rx.c             |   2 +
 drivers/net/wireless/ath/carl9170/tx.c             |   7 +
 drivers/net/wireless/atmel_pci.c                   |   6 +-
 drivers/net/wireless/b43/pcmcia.c                  |   6 +-
 drivers/net/wireless/b43/sdio.c                    |   6 +-
 drivers/net/wireless/brcm80211/brcmfmac/fweh.c     |   4 +-
 drivers/net/wireless/brcm80211/brcmfmac/fweh.h     |   2 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  | 141 +++---
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |   3 -
 drivers/net/wireless/brcm80211/brcmsmac/debug.c    | 112 +++++
 drivers/net/wireless/brcm80211/brcmsmac/debug.h    |  23 +
 drivers/net/wireless/brcm80211/brcmsmac/dma.c      |   4 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |  33 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |  61 +--
 .../net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c  | 471 +++++++++++++----=
----
 .../wireless/brcm80211/brcmsmac/phy/phytbl_lcn.c   |  64 +--
 drivers/net/wireless/brcm80211/brcmsmac/pub.h      |   5 +-
 drivers/net/wireless/ipw2x00/ipw2100.c             |   4 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |  12 +-
 drivers/net/wireless/iwlegacy/3945-mac.c           |   4 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |   4 +-
 drivers/net/wireless/iwlwifi/dvm/rxon.c            |  12 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |   4 +-
 drivers/net/wireless/libertas/cfg.c                |   9 +-
 drivers/net/wireless/libertas/if_spi.c             |   6 +-
 drivers/net/wireless/mac80211_hwsim.c              |   7 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |  15 +
 drivers/net/wireless/mwifiex/fw.h                  |   2 +
 drivers/net/wireless/mwifiex/sta_ioctl.c           |  36 +-
 drivers/net/wireless/mwifiex/usb.c                 |   2 +-
 drivers/net/wireless/mwl8k.c                       |  14 +-
 drivers/net/wireless/orinoco/orinoco_nortel.c      |   4 +-
 drivers/net/wireless/orinoco/orinoco_pci.c         |   4 +-
 drivers/net/wireless/orinoco/orinoco_plx.c         |   4 +-
 drivers/net/wireless/orinoco/orinoco_tmd.c         |   4 +-
 drivers/net/wireless/p54/eeprom.c                  |   5 +-
 drivers/net/wireless/p54/p54pci.c                  |  19 +-
 drivers/net/wireless/p54/p54spi.c                  |   6 +-
 drivers/net/wireless/p54/p54usb.c                  |   6 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |   2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |   2 +-
 drivers/net/wireless/rt2x00/rt2800.h               |   6 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            | 142 +++----
 drivers/net/wireless/rt2x00/rt2800pci.c            |   4 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |  10 +
 drivers/net/wireless/rt2x00/rt61pci.c              |   2 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |   6 +-
 drivers/net/wireless/rtl818x/rtl8187/dev.c         |   6 +-
 drivers/net/wireless/rtlwifi/pci.c                 |   4 +-
 drivers/net/wireless/rtlwifi/pci.h                 |   4 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |   9 +-
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c        |  11 +-
 drivers/net/wireless/rtlwifi/rtl8192se/def.h       |   3 +-
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c        |  20 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |   3 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.h        |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c        |  20 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c        |   9 +-
 drivers/net/wireless/rtlwifi/usb.c                 |   2 +-
 drivers/net/wireless/rtlwifi/usb.h                 |   2 +-
 drivers/net/wireless/ti/wl1251/main.c              |   4 +-
 drivers/net/wireless/ti/wl1251/sdio.c              |   4 +-
 drivers/net/wireless/ti/wl1251/spi.c               |   6 +-
 drivers/net/wireless/ti/wl12xx/main.c              |   6 +-
 drivers/net/wireless/ti/wl18xx/main.c              |   6 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |   4 +-
 drivers/net/wireless/ti/wlcore/main.c              |   4 +-
 drivers/net/wireless/ti/wlcore/sdio.c              |   8 +-
 drivers/net/wireless/ti/wlcore/spi.c               |   6 +-
 drivers/net/wireless/ti/wlcore/wlcore.h            |   4 +-
 drivers/ssb/driver_chipcommon.c                    | 100 ++++-
 drivers/ssb/driver_chipcommon_pmu.c                |  27 ++
 drivers/ssb/driver_extif.c                         |  24 +-
 drivers/ssb/driver_mipscore.c                      |  14 +-
 drivers/ssb/embedded.c                             |  35 ++
 drivers/ssb/main.c                                 |   8 +
 drivers/ssb/ssb_private.h                          |  31 ++
 include/linux/bcm47xx_wdt.h                        |  19 +
 include/linux/bcma/bcma_driver_chipcommon.h        |   7 +-
 include/linux/ieee80211.h                          |  15 +
 include/linux/ssb/ssb.h                            |   2 +
 include/linux/ssb/ssb_driver_chipcommon.h          |   5 +-
 include/linux/ssb/ssb_driver_extif.h               |  52 ++-
 include/net/bluetooth/hci_core.h                   |  31 +-
 include/net/bluetooth/l2cap.h                      |   2 +-
 include/net/cfg80211.h                             |  69 ++-
 include/net/ieee80211_radiotap.h                   |  24 ++
 include/net/mac80211.h                             |  12 +-
 include/uapi/linux/nl80211.h                       |  16 +
 net/bluetooth/hci_core.c                           |   5 +
 net/bluetooth/hci_event.c                          |  56 ++-
 net/bluetooth/l2cap_core.c                         | 100 ++---
 net/bluetooth/mgmt.c                               |  10 +-
 net/bluetooth/rfcomm/sock.c                        |   4 +-
 net/bluetooth/sco.c                                |  86 +++-
 net/mac80211/cfg.c                                 |  77 ++--
 net/mac80211/debugfs_sta.c                         |  36 ++
 net/mac80211/ieee80211_i.h                         |   5 +-
 net/mac80211/iface.c                               |  45 ++
 net/mac80211/main.c                                |   5 +-
 net/mac80211/mesh_plink.c                          |   3 +-
 net/mac80211/mesh_sync.c                           |   4 +
 net/mac80211/mlme.c                                | 431 +++++++++++++++--=
--
 net/mac80211/offchannel.c                          |   2 -
 net/mac80211/rc80211_minstrel_ht.c                 |   8 +-
 net/mac80211/rx.c                                  |  42 +-
 net/mac80211/scan.c                                |  21 +-
 net/mac80211/sta_info.h                            |   4 +
 net/mac80211/status.c                              |   3 +
 net/mac80211/tx.c                                  |   9 +-
 net/mac80211/util.c                                |  58 ++-
 net/nfc/llcp/llcp.c                                |   5 +-
 net/rfkill/rfkill-gpio.c                           |   2 +-
 net/rfkill/rfkill-regulator.c                      |   6 +-
 net/wireless/chan.c                                |  92 ++--
 net/wireless/core.h                                |   8 -
 net/wireless/mesh.c                                |   3 +-
 net/wireless/nl80211.c                             | 155 +++----
 net/wireless/reg.c                                 |   2 +-
 net/wireless/reg.h                                 |   2 +-
 net/wireless/scan.c                                | 452 ++++++++++-------=
---
 net/wireless/sme.c                                 |  13 +-
 net/wireless/util.c                                |   9 +-
 net/wireless/wext-sme.c                            |   8 +-
 147 files changed, 2860 insertions(+), 1428 deletions(-)
 create mode 100644 include/linux/bcm47xx_wdt.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--liOOAslEiF7prFVr
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQwjwyAAoJEJctW/TcYTgG7MgP/Rp1eeI0NbVZS4F10o4pzc3O
4lsvxBoItXwp1oRNVKuVkxsyqdKzteA+hGwxaNP3YDtngNpI93NW82atuVM85qKy
NcXgyoO5n9SbChEssAxkSBP2dtFvNnfF0ipx1nI8aqeHmDS4HNBMEFf0LHALajt7
s9gHyZl7DXXcFguXEZHLt+WLnRcIeRygs+x+NlwOdeUDCjilHmElI+f6wf3zaagu
T5Kf5ZzkDEfRphlgDERBXiEdNHvrWUaHbgF5ehI6ct9TmSIick1Xb1P2cHbEWk7k
vWPdgMvy3ybRYJUvaFnTe1ifmHVH3CpjQTX0GOTri8trPluPThP8JbQIpSCGaH/T
3q/nbQgFOC+L2SJ05isQ5mrwSPy9ny76MqOBrMUyjsJwr8kaFdaUZ63TEmD+rLjz
IQdk1nvEsC0IydL/qM+aGRTsstR92vN7NL3BW7WBjTFJ1378zEKCjQgd5zAvewwO
ybzU07u0gonEbya3+5+kQA0ffPLdzpJ3v17qz2UH5TLsivtqLfTqNNt0hspu7xXB
6fWyGCFYX8t+phv3rijTS9NvIEeCMmiIsgubYrw70i8czv+2pMyTk78/YaN4DMqq
aIKIdFC3ZGxplKh3c41t3XeNyVsd9Vs2OIO0n/fc8TnklLxWzV7MfabidUWXKQU5
w00hBOKZuQ29GAjlz+b6
=zzGl
-----END PGP SIGNATURE-----

--liOOAslEiF7prFVr--
