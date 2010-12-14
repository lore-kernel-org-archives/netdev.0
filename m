From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2010-12-14
Date: Tue, 14 Dec 2010 11:19:05 -0500
Message-ID: <20101214161904.GC2389@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45486 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759599Ab0LNQaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 11:30:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is another batch of updates intended for 2.6.38.  This batch
includes some mac80211 updates from Johannes Berg, Felix Fietkau,
and Helmut Schaa, some ath cleanups from Joe Perches, more b43 N-phy
updates from Rafa=C5=82 Mi=C5=82ecki, more ath5k updates from Nick Koss=
ifidis,
some ath9k bits from the Atheros guys, and a smattering of other bits.
This also includes another wireless-2.6 pull to grab some prerequisites
for later patches.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 0dbaee3b37e118a96bb7b8eb0d9bbaeeb462=
64be:

  net: Abstract default ADVMSS behind an accessor. (2010-12-13 12:52:14=
 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Amitkumar Karwar (1):
      cfg80211: add some element IDs in enum ieee80211_eid

Ben Greear (3):
      ath9k: Make DMA warning in ath_stoprecv WARN_ON_ONCE.
      ath9k: Check for NULL sta in ath_tx_start
      mac80211: Show max number of probe tries in debug message.

Bruno Randolf (4):
      ath5k: Use EWMA factor of 1024 instead of 1000
      lib: Improve EWMA efficiency by using bitshifts
      nl80211/mac80211: Report signal average
      ath5k: Use capabilities information for the number of TX queues

David Kilroy (4):
      orinoco: allow IW_AUTH_MFP to pass through
      orinoco: initialise priv->hw before assigning the interrupt
      orinoco: clear countermeasure setting on commit
      orinoco: fix TKIP countermeasure behaviour

Eliad Peller (1):
      mac80211: fix dynamic-ps/pm_qos magic numbers

=46elix Fietkau (4):
      mac80211: remove a redundant check
      mac80211: speed up AP probing using nullfunc frames
      ath9k: fix a DMA related race condition on reset
      mac80211: fix a compiler warning

Grumbach, Emmanuel (1):
      iwlagn: Enable PCI L1 ACTIVE state after uCode has been loaded

Helmut Schaa (4):
      mac80211: Update last_tx_rate only for data frames
      mac80211: Fix BUG in pskb_expand_head when transmitting shared sk=
bs
      cfg80211: Add new BSS attribute ht_opmode
      mac80211: Apply ht_opmode changes in ieee80211_change_bss

Javier Cardona (5):
      nl80211/mac80211: define and allow configuring mesh element TTL
      mac80211: Fix compilation error when mesh is disabled
      ath5k: Fix beaconing in mesh mode
      ath5k: Prevent mesh interfaces from being counted as ad-hoc
      ath5k: Put the right tsf value in mesh beacons

Joe Perches (5):
      MAINTAINERS: Add ATH GENERIC UTILITIES
      ath: Add and use ath_printk and ath_<level>
      ath: Convert ath_print(.., ATH_DBG_FATAL to ath_err
      ath: Convert ath_print to ath_dbg
      ath: Fix ath_dbg access beyond array bound

Johannes Berg (4):
      mac80211: move mesh filter adjusting
      cfg80211: require add_virtual_intf to return new dev
      nl80211: refactor mesh parameter parsing
      cfg80211/mac80211: add mesh join/leave commands

John W. Linville (5):
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      ath5k: remove MODULE_VERSION
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      ath: fix build break with ATH_DBG_WARN_ON_ONCE
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Luis R. Rodriguez (2):
      ath9k: skip ATH9K_INT_TIM_TIMER when we are idle
      ath9k_hw: warn if we cannot change the power to the chip

Matteo Croce (1):
      ath9k: fix bug in tx power

Mohammed Shafi Shajakhan (3):
      ath9k: Properly use unlikely check macro
      ath9k: Parse DTIM period from mac80211
      ath9k: Remove dead code in recv.c

Nick Kossifidis (5):
      ath5k: Always write tx powertable on hw
      ath5k: Always free tx buffers before reset
      ath5k: Disable ANI during reset
      ath5k: Fix reporting of RX dma stop failure
      ath5k: Include tx ack reporting on hw flags

Rafa=C5=82 Mi=C5=82ecki (8):
      b43: N-PHY: update init tables
      b43: N-PHY: reorder and optimize tables initialization
      b43: N-PHY: implement own maskset
      b43: flush PHY writes when needed
      b43: N-PHY: silence warnings
      b43: set TMS to work with current band width for N-PHY
      b43: fix split of N-PHY devices into supported and not (based on =
PHY rev)
      b43: rename config option for N-PHY, drop BROKEN

Rajkumar Manoharan (1):
      ath9k: fix beacon resource related race condition

Sedat Dilek (1):
      ath5k: Fix modinfo does not list alias -> pci-id lines

Senthil Balasubramanian (1):
      ath9k: Fix STA disconnect issue due to received MIC failed bcast =
frames

Stanislaw Gruszka (2):
      iwl3945: prevent too frequent firmware resets
      iwlwifi: jiffies based tx queues watchdog

Sujith Manoharan (4):
      ath9k_htc: Cleanup device identification
      ath9k_htc: Add support for handling TX power configuration
      ath9k_htc: Fix panic on FW download failure
      ath9k_htc: Fix suspend/resume

Vasanthakumar Thiagarajan (26):
      ath9k_hw: Define hw version macros for AR9485
      ath9k_hw: Add initvals.h for AR9485
      ath9k_hw: Enable hw initialization for AR9485
      ath9k_hw: Initialize mode registers for AR9485
      ath9k_hw: Initialize tx/rx gain table from initvals.h for AR9485
      ath9k_hw: Eeeprom changes for AR9485
      ath9k_hw: Disable LDPC for AR9485
      ath9k: Disable TX STBC for AR9485
      ath9k: Enable extended synch for AR9485 to fix L0s recovery issue
      ath9k_hw: Find the maximum number of chains that hw supports
      ath9k: Configure pll control for AR9485
      ath9k_hw: Find chansel of AR_PHY_65NM_CH0_SYNTH7 for AR9485
      ath9k_hw: Add a helper function to get spur channel pointer from =
cal data for AR9003 family
      ath9k: Read spur channel information from eeprom for AR9485
      ath9k_hw: Configure xpa bias level for AR9485
      ath9k_hw: Read and configure antenna diversity control for AR9485
      ath9k_hw: Configure internal regulator for AR9485
      ath9k_hw: Read and configure turnning caps to regulate freq accur=
acy
      ath9k_hw: Configure power control only for the supported chains
      ath9k_hw: Program appropriate chianmask for AR9485 before startin=
g AGC/IQ cal
      ath9k_hw: Define IQcal correction coefficient registers using ind=
ex
      ath9k_hw: Add IQ cal changes for AR9485
      ath9k_hw: Program appropriate register for temperature compensati=
on cal for AR9485
      ath9k_hw: Setup paprd only for supported chains
      ath9k_hw: Disable MRC CCK for AR9485
      ath9k: Add device id of AR9485 to pci table

Wey-Yi Guy (4):
      iwlagn: fix race condition when reprogram sta
      iwlagn: remove structure name reference to gen2
      iwlwifi: check for STATUS_EXIT_PENDING when send RXON command
      iwlagn: name change for bt_ch_announce module parameter

 MAINTAINERS                                      |    6 +
 drivers/net/wireless/ath/ath.h                   |  115 +++-
 drivers/net/wireless/ath/ath5k/base.c            |  103 ++-
 drivers/net/wireless/ath/ath5k/debug.c           |    1 -
 drivers/net/wireless/ath/ath5k/dma.c             |    2 +-
 drivers/net/wireless/ath/ath5k/pci.c             |    1 +
 drivers/net/wireless/ath/ath5k/phy.c             |   33 +-
 drivers/net/wireless/ath/ath5k/qcu.c             |    4 +-
 drivers/net/wireless/ath/ath9k/ahb.c             |    7 +-
 drivers/net/wireless/ath/ath9k/ani.c             |   99 ++--
 drivers/net/wireless/ath/ath9k/ar5008_phy.c      |  199 ++---
 drivers/net/wireless/ath/ath9k/ar9002_calib.c    |  220 +++---
 drivers/net/wireless/ath/ath9k/ar9002_hw.c       |    6 +-
 drivers/net/wireless/ath/ath9k/ar9002_mac.c      |   20 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c    |  473 ++++++++---
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c   |  361 +++++----
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h   |    2 +
 drivers/net/wireless/ath/ath9k/ar9003_hw.c       |  278 +++++--
 drivers/net/wireless/ath/ath9k/ar9003_mac.c      |   16 +-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c    |   37 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c      |  245 +++---
 drivers/net/wireless/ath/ath9k/ar9003_phy.h      |   70 ++-
 drivers/net/wireless/ath/ath9k/ar9485_initvals.h |  943 ++++++++++++++=
++++++++
 drivers/net/wireless/ath/ath9k/ath9k.h           |    2 +-
 drivers/net/wireless/ath/ath9k/beacon.c          |   79 +-
 drivers/net/wireless/ath/ath9k/calib.c           |   59 +-
 drivers/net/wireless/ath/ath9k/common.c          |    4 +-
 drivers/net/wireless/ath/ath9k/common.h          |    1 -
 drivers/net/wireless/ath/ath9k/eeprom.c          |    4 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c       |   72 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c     |   45 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c      |   79 +-
 drivers/net/wireless/ath/ath9k/gpio.c            |   20 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c         |   43 +-
 drivers/net/wireless/ath/ath9k/hif_usb.h         |    2 +
 drivers/net/wireless/ath/ath9k/htc.h             |    3 +
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c  |   24 +-
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c    |   15 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c    |   78 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c    |  202 +++---
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c    |   33 +-
 drivers/net/wireless/ath/ath9k/hw.c              |  201 +++---
 drivers/net/wireless/ath/ath9k/hw.h              |    7 +-
 drivers/net/wireless/ath/ath9k/init.c            |   35 +-
 drivers/net/wireless/ath/ath9k/mac.c             |  120 ++--
 drivers/net/wireless/ath/ath9k/main.c            |  216 +++---
 drivers/net/wireless/ath/ath9k/pci.c             |   20 +-
 drivers/net/wireless/ath/ath9k/phy.h             |    1 +
 drivers/net/wireless/ath/ath9k/rc.c              |   18 +-
 drivers/net/wireless/ath/ath9k/recv.c            |   81 +-
 drivers/net/wireless/ath/ath9k/reg.h             |   18 +-
 drivers/net/wireless/ath/ath9k/virtual.c         |    7 +-
 drivers/net/wireless/ath/ath9k/wmi.c             |   12 +-
 drivers/net/wireless/ath/ath9k/xmit.c            |  100 +--
 drivers/net/wireless/ath/debug.c                 |   20 -
 drivers/net/wireless/ath/debug.h                 |   92 ---
 drivers/net/wireless/ath/key.c                   |   28 +-
 drivers/net/wireless/ath/main.c                  |   20 +
 drivers/net/wireless/b43/Kconfig                 |   13 +-
 drivers/net/wireless/b43/Makefile                |    8 +-
 drivers/net/wireless/b43/main.c                  |   12 +-
 drivers/net/wireless/b43/phy_common.c            |   14 +-
 drivers/net/wireless/b43/phy_common.h            |    8 +
 drivers/net/wireless/b43/phy_n.c                 |   26 +-
 drivers/net/wireless/b43/tables_nphy.c           |  224 +++---
 drivers/net/wireless/iwlwifi/iwl-1000.c          |    3 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c          |    7 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c          |    4 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c          |    4 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c          |   28 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c       |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c      |    3 +
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c     |    4 +
 drivers/net/wireless/iwlwifi/iwl-agn.c           |   91 +--
 drivers/net/wireless/iwlwifi/iwl-agn.h           |   20 +-
 drivers/net/wireless/iwlwifi/iwl-core.c          |  111 ++--
 drivers/net/wireless/iwlwifi/iwl-core.h          |   10 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c       |   24 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h           |   16 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c           |   13 +
 drivers/net/wireless/iwlwifi/iwl-tx.c            |    2 -
 drivers/net/wireless/iwlwifi/iwl3945-base.c      |   28 +-
 drivers/net/wireless/orinoco/main.c              |    6 +
 drivers/net/wireless/orinoco/orinoco_cs.c        |   14 +-
 drivers/net/wireless/orinoco/spectrum_cs.c       |   14 +-
 drivers/net/wireless/orinoco/wext.c              |   12 +-
 include/linux/average.h                          |    4 +-
 include/linux/ieee80211.h                        |    3 +
 include/linux/nl80211.h                          |   18 +
 include/net/cfg80211.h                           |   58 +-
 lib/average.c                                    |   20 +-
 net/mac80211/Kconfig                             |    1 +
 net/mac80211/cfg.c                               |   70 ++-
 net/mac80211/debugfs_netdev.c                    |    2 +
 net/mac80211/ieee80211_i.h                       |   16 +-
 net/mac80211/iface.c                             |   30 +-
 net/mac80211/main.c                              |    5 +-
 net/mac80211/mesh.c                              |   36 +-
 net/mac80211/mesh.h                              |   23 -
 net/mac80211/mesh_hwmp.c                         |    9 +-
 net/mac80211/mesh_pathtbl.c                      |    7 +-
 net/mac80211/mlme.c                              |  104 ++-
 net/mac80211/rx.c                                |    1 +
 net/mac80211/sta_info.c                          |    2 +
 net/mac80211/sta_info.h                          |    3 +
 net/mac80211/status.c                            |   18 +-
 net/mac80211/tx.c                                |   28 +-
 net/mac80211/work.c                              |    5 +-
 net/wireless/Makefile                            |    2 +-
 net/wireless/core.c                              |   15 +-
 net/wireless/core.h                              |   13 +
 net/wireless/mesh.c                              |  140 ++++
 net/wireless/nl80211.c                           |  212 ++++-
 net/wireless/util.c                              |    1 +
 114 files changed, 4237 insertions(+), 2331 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9485_initvals.h
 delete mode 100644 drivers/net/wireless/ath/debug.h
 create mode 100644 net/wireless/mesh.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2010-12-14.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
