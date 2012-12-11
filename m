From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2012-12-11
Date: Tue, 11 Dec 2012 16:55:46 -0500
Message-ID: <20121211215546.GA3566@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56051 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251Ab2LKWBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 17:01:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

This is a roll-up of some late-breaking activity intended for 3.8.
The extra week of waiting for 3.7 left people a bit restless!

There are two pull requests...

=46or the mac80211 pull, Johannes says:

"Please pull my mac80211-next tree to get a few updates: I mostly have
fixes for code that's currently in the -next trees, but there are still
a few improvements as well."

=46or the iwlwifi pull, Johannes says:

"Please pull to get a few small fixes, some improvements and a bit of
infrastructure work in iwlwifi."

Otherwise, there is nothing too unusual here -- some normal levels
of attention paid to brcmfmac, and ath9k, a couple of late fixes for
some new bcma code, and a handful of other bits.

Please let me know if there are problems!

John

---

The following changes since commit 75be437230b06fca87908a787f70de0ce7fb=
ab8c:

  net: gro: avoid double copy in skb_gro_receive() (2012-12-11 13:44:09=
 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.=
git for-davem

for you to fetch changes up to f9c4d420c12de65e58a1a14ccee03e8b5cf99f5b=
:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/linville/wireless-next into for-davem (2012-12-11 16:24:55 -0500)

----------------------------------------------------------------

Arend van Spriel (10):
      brcmfmac: rework bus interface
      brcmsmac: fix uninitialized variable warning on arm architecture
      brcmfmac: use one list of event defintions
      brcmfmac: error messages should not be suppressed
      brcmfmac: consolidate debug macros in wl_cfg80211
      brcmfmac: replace WL_ERR() with brcmf_err()
      brcmfmac: replace WL_INFO() macro
      brcmfmac: remove WL_TRACE() macro
      brcmfmac: remove WL_SCAN() macro
      brcmfmac: remove WL_CONN() macro

Chaitanya (1):
      mac80211: warn only once if ampdu_action isn't assigned

Christian Lamparter (1):
      carl9170: fix copy and paste mishap in carl9170_handle_mpdu

Cong Ding (1):
      ssb: use WARN in main.c

Emmanuel Grumbach (7):
      iwlwifi: read the Rx write pointer only once
      iwlwifi: clear trans->op_mode pointer when it is leaving
      iwlwifi: return real info in probe failure
      iwlwifi: move prph handling into the transport
      iwlwifi: reset_ict in stop_hw
      iwlwifi: silently ignore fw flaws in Tx path
      iwlwifi: don't handle masked interrupt

Eytan Lifshitz (1):
      iwlwifi: Change define and struct names in iwl-eeprom-parse.h

=46elix Fietkau (4):
      Revert "ath9k_hw: Update AR9003 high_power tx gain table"
      ath9k_hw: Fix signal strength / channel noise reporting
      ath5k: fix tx path skb leaks
      b43: fix tx path skb leaks

Gabor Juhos (6):
      ath9k: ar9003: fix OTP register offsets for AR9340
      ath9k: move duplicated debug message to 'ath9k_hw_nvram_read'
      ath9k: add EEPROM offset to debug message
      ath9k: use 'struct ath_hw *' as the first argument for 'ath9k_hw_=
nvram_read'
      ath9k: allow to load EEPROM content via firmware API
      ath9k: check pdata variable before dereferencing it

Hauke Mehrtens (3):
      brcmsmac: add support for cores with revision 17
      brcmsmac: do a read after the write of the objmem on broken PCIe =
controllers
      brcmsmac: add support for BCM43224 with PCI id of 14e4:a8d8

Helmut Schaa (1):
      mac80211: skip radiotap space calculation if no monitor exists

Johannes Berg (7):
      cfg80211: check no-OFDM flag for channels wider than 20 MHz
      wireless: fix VHT max AMPDU exponent definition
      mac80211: cancel work instead of waiting for it to do nothing
      iwlwifi: change TX code to suppress smatch warning
      wext: explicitly cast -110 to u8
      mac80211: a few whitespace fixes
      minstrel: update stats after processing status

John W. Linville (4):
      rt2800usb: reorganize 2001:3c1e in usb id table Wi-Fi adapter
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwi=
fi-next
      Merge branch 'for-john' of git://git.sipsolutions.net/mac80211-ne=
xt
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next into for-davem

Larry Finger (1):
      b43legacy: Fix firmware loading when driver is built into the ker=
nel

Maia Kozheva (1):
      rt2800usb: Add support for 2001:3c1e (D-Link DWA-125 rev B1) USB =
Wi-Fi adapter

Marco Porsch (1):
      mac80211: don't drop mesh peering frames from unknown STA

Rafa=C5=82 Mi=C5=82ecki (2):
      bcma: unify naming schema for clock functions
      bcma: mips: fix clearing device IRQ

Saravana (1):
      mac80211: add debug file for mic failure

Simon Wunderlich (1):
      mac80211: adapt slot time in IBSS mode

Stanislaw Gruszka (2):
      mac80211: introduce IEEE80211_HW_TEARDOWN_AGGR_ON_BAR_FAIL
      Revert: "rt2x00: Don't let mac80211 send a BAR when an AMPDU subf=
rame fails"

Sujith Manoharan (10):
      ath9k: Fix regression in 'xmit' debugfs file
      ath9k_hw: Fix PAPRD registers for AR9485
      ath9k_hw: Fix PAPRD training
      ath9k: Add a few debug messages for PAPRD
      ath9k: Fix redundant PS wrappers
      ath9k_hw: Various trivial fixes for PAPRD
      ath9k_hw: Fix PAPRD retraining for AR9485
      ath9k_hw: Add HW cap for PAPRD
      ath9k_hw: Calculate the correct training power for PAPRD
      ath9k_hw: Update intivals for AR9340

Thomas Pedersen (3):
      ath9k: RX timestamp is reported at end of frame
      ath9k_htc: RX timestamp is reported at end of frame
      ath5k: RX timestamp is reported at end of frame

Tim Gardner (1):
      iwlwifi: iwlagn_request_scan: Fix check for priv->scan_request

 drivers/bcma/bcma_private.h                        |   4 +-
 drivers/bcma/driver_chipcommon.c                   |  10 +-
 drivers/bcma/driver_chipcommon_pmu.c               |  39 +-
 drivers/bcma/driver_mips.c                         |   4 +-
 drivers/net/wireless/ath/ath5k/base.c              |  17 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |   2 +-
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   | 172 ++---
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |  66 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |   6 +-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |  87 ++-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |  29 +-
 drivers/net/wireless/ath/ath9k/ar9340_initvals.h   |   6 +-
 drivers/net/wireless/ath/ath9k/calib.c             |   1 +
 drivers/net/wireless/ath/ath9k/calib.h             |   3 +
 drivers/net/wireless/ath/ath9k/debug.h             |   2 +-
 drivers/net/wireless/ath/ath9k/eeprom.c            |  29 +-
 drivers/net/wireless/ath/ath9k/eeprom.h            |   2 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |   8 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |   9 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |  10 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |   2 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   4 +
 drivers/net/wireless/ath/ath9k/hw.h                |   7 +-
 drivers/net/wireless/ath/ath9k/init.c              |  60 +-
 drivers/net/wireless/ath/ath9k/link.c              |  22 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   2 +-
 drivers/net/wireless/ath/carl9170/rx.c             |   2 +-
 drivers/net/wireless/b43/dma.c                     |   7 +-
 drivers/net/wireless/b43/main.c                    |  12 +-
 drivers/net/wireless/b43/pio.c                     |   4 +-
 drivers/net/wireless/b43legacy/b43legacy.h         |   5 +
 drivers/net/wireless/b43legacy/main.c              |  37 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |  15 +-
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |  44 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |   1 -
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |  92 ++-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c  |  25 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |  40 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.c  |   5 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h  |  35 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |  57 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c | 205 +++---
 drivers/net/wireless/brcm80211/brcmfmac/fweh.c     |  84 +--
 drivers/net/wireless/brcm80211/brcmfmac/fweh.h     | 142 ++--
 drivers/net/wireless/brcm80211/brcmfmac/fwil.c     |  14 +-
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.c    |  14 +-
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |  91 +--
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  | 817 +++++++++++--=
--------
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |  70 +-
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.c  |   2 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   1 +
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |  13 +-
 drivers/net/wireless/iwlwifi/dvm/calib.c           |  14 +-
 drivers/net/wireless/iwlwifi/dvm/debugfs.c         |  12 +-
 drivers/net/wireless/iwlwifi/dvm/dev.h             |   2 +-
 drivers/net/wireless/iwlwifi/dvm/devices.c         |   8 +-
 drivers/net/wireless/iwlwifi/dvm/lib.c             |   8 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |  12 +-
 drivers/net/wireless/iwlwifi/dvm/main.c            |  57 +-
 drivers/net/wireless/iwlwifi/dvm/rs.c              |  44 +-
 drivers/net/wireless/iwlwifi/dvm/rxon.c            |   4 +-
 drivers/net/wireless/iwlwifi/dvm/scan.c            |  13 +-
 drivers/net/wireless/iwlwifi/dvm/sta.c             |  12 +-
 drivers/net/wireless/iwlwifi/dvm/tx.c              |  67 +-
 drivers/net/wireless/iwlwifi/dvm/ucode.c           |  12 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |   8 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |  34 +
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   6 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c    |  84 ++-
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.h    |  45 +-
 drivers/net/wireless/iwlwifi/iwl-io.c              |  40 +-
 drivers/net/wireless/iwlwifi/iwl-io.h              |  10 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |  22 +-
 drivers/net/wireless/iwlwifi/pcie/1000.c           |   8 +-
 drivers/net/wireless/iwlwifi/pcie/2000.c           |  16 +-
 drivers/net/wireless/iwlwifi/pcie/5000.c           |  12 +-
 drivers/net/wireless/iwlwifi/pcie/6000.c           |  28 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |  11 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |  14 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |  18 +
 drivers/net/wireless/mac80211_hwsim.c              |   2 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |   3 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |   1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   7 +-
 drivers/ssb/main.c                                 |   3 +-
 include/linux/ath9k_platform.h                     |   2 +
 include/linux/ieee80211.h                          |  54 +-
 include/net/mac80211.h                             |   5 +
 net/mac80211/agg-tx.c                              |   2 +-
 net/mac80211/debugfs_key.c                         |  17 +
 net/mac80211/ibss.c                                |  14 +
 net/mac80211/iface.c                               |   2 +-
 net/mac80211/key.h                                 |   3 +
 net/mac80211/mlme.c                                |   4 +-
 net/mac80211/rc80211_minstrel.c                    |   9 +-
 net/mac80211/rx.c                                  |   9 +-
 net/mac80211/scan.c                                |   2 +-
 net/mac80211/status.c                              |   6 +-
 net/mac80211/wpa.c                                 |   5 +-
 net/wireless/chan.c                                |   3 +
 net/wireless/wext-compat.c                         |   2 +-
 101 files changed, 1741 insertions(+), 1472 deletions(-)
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
