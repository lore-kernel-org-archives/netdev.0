From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2012-03-16
Date: Fri, 16 Mar 2012 14:04:29 -0400
Message-ID: <20120316180428.GD2563@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 01a282980937f9ca55a3cb06b9c6ff1cc49ea396

Dave,

Yet another batch of updates intended for 3.4 -- they keep on
coming! :-)

Highlights here include a batch of ath6kl updates, a batch of mwifiex
code cleanups, a number of mac80211 refactoring patches from Johannes,
the usual level of activity around iwlwifi and ath9k, and a handful
of updates to other drivers.

Please let me know if there are problems!

John

P.S.  This pull request should also resolve the linux-next merge
issue Stephen reported today.

---

The following changes since commit d5ddb4a59ed43b4c569b4efa8b508d50ef140cc6:

  cdc_ncm: avoid discarding datagrams in rx path (2012-03-16 02:08:36 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git for-davem

Aarthi Thiruvengadam (2):
      ath6kl: Clear the IE in firmware if not set
      ath6kl: Fix merge error in ath6kl_set_ies()

Amitkumar Karwar (1):
      mwifiex: correction in structure name passed to sizeof()

Ashok Nagarajan (2):
      mac80211_hwsim: Fix set mactime on receiver hwsim radio
      ath9k: Fix mactime from being clobbered in rx_status

Bala Shanmugam (1):
      cfg80211: Add background scan period attribute.

Ben Greear (1):
      ath9k: Add wiphy name to log messages.

Chilam Ng (2):
      ath6kl: prioritize Tx bundling based on AC priorities
      ath6kl: assign Tx packet drop threshold per endpoint based on AC priority

Daniel Drake (1):
      libertas: remove dump_survey implementation

David Spinadel (6):
      iwlwifi: avoid some operations if no uCode loaded
      iwlwifi: explicitly track whether INIT uCode was run
      iwlwifi: more modularity in fw images and sections
      iwlwifi: Add TLVs and fields for 16.0 uCode
      iwlwifi: change struct iwl_fw
      iwlwifi: Add bool mvm_ucode to iwl_fw

Eliad Peller (2):
      mac80211: add NULL terminator to debugfs_netdev write buf
      mac80211: make uapsd_* keys per-vif

Etay Luz (2):
      ath6kl: add padding to firmware log records
      ath6kl: Collect residue firmware logs

Felix Fietkau (15):
      ath9k: fix going to full-sleep on PS idle
      ath9k_hw: simplify tx queue interrupt mask handling
      ath9k_hw: clean up tx completion interrupt handling
      ath9k_hw: remove ath9k_hw_htc_resetinit
      ath9k_hw: remove ath9k_hw_getdefantenna
      ath9k: optimize register access functions
      ath9k_hw: remove ath9k_hw_gettxintrtxqs
      ath9k_hw: clean up ath9k_hw_setuprxdesc
      ath9k_hw: remove iniCommon_*_cck_fir_coeff_9271
      ath9k_hw: fold ar9002_hw_cck_chan14_spread into mode regs initialization
      ath9k_hw: fix AR9380 register settings for channel 14
      ath9k_hw: clean up iniModesAdditional
      ath9k_hw: remove iniModes_*_tx_gain_9271
      ath9k: inline AR9271 1.0 INI overrides
      ath9k_hw: remove unused initvals

Helmut Schaa (5):
      mac80211: Limit TID buffering during BA session setup/teardown
      mac80211: Disable MCS > 7 in minstrel_ht when STA uses static SMPS
      rt2x00: Fix beacon skew in rt2800pci
      rt2x00: Set IEEE80211_HW_REPORTS_TX_ACK_STATUS in rt2800
      mac80211: Don't sample max throughput rate in minstrel_ht

Johannes Berg (17):
      mac80211: remove tx_sync
      mac80211: set channel back after disassociating
      mac80211: add auth/assoc/deauth flow diagram
      iwlwifi: remove TX hex debug
      iwlwifi: abstract out missing SEQ_RX_FRAME workaround
      iwlwifi: convert bad state message into warning
      mac80211: move misplaced comment
      mac80211: simplify HT checks
      mac80211: simplify wmm check during association
      mac80211: remove spurious BSSID change flag
      mac80211: refactor common auth/assoc setup code
      mac80211: set basic rates earlier
      mac80211: move RX WEP weak IV counting
      mac80211: linearize SKBs as needed for crypto
      brmc80211: dont use jiffies for BSS TSF
      cfg80211: clarify timestamp in cfg80211_inform_bss
      mac80211: rename bss_conf timestamp to last_tsf

John W. Linville (2):
      Merge branch 'for-linville' of git://github.com/kvalo/ath6kl
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next into for-davem

Kalle Valo (20):
      ath6kl: store firmware logs in skbuffs
      ath6kl: add blocking debugfs file for retrieving firmware logs
      Merge remote branch 'wireless-next/master' into ath6kl-next
      ath6kl: fix pointer style
      ath6kl: fix checkpatch error with EPSTAT() macro
      ath6kl: alignment should match open parenthesis
      ath6kl: logical continuations should be on the previous line
      ath6kl: remove multiple assignments
      ath6kl: add ath6kl_bmi_write_hi32()
      ath6kl: add ath6kl_bmi_read_hi32()
      ath6kl: fix error handling ath6kl_target_config_wlan_params()
      ath6kl: fix open paranthesis alignment in ath6kl_cfg80211_connect()
      ath6kl: document all spinlocks
      ath6kl: fix too long lines
      ath6kl: make ath6kl_bmi_[read|write]_hi32() endian safe
      ath6kl: fix regression in ath6kl_upload_board_file()
      ath6kl: replace strict_strtoul() with kstrtoul()
      ath6kl: fix open parenthesis alignment in ath6kl_sdio_suspend()
      ath6kl: use max_t() in ath6kl_cfg80211_connect()
      ath6kl: fix debug.c file mode

Larry Finger (2):
      b43legacy: Load firmware from work queue instead of from probe routine
      b43: Load firmware from a work queue and not from the probe routine

Meenakshi Venkataraman (1):
      iwlwifi: move wait_command_queue from shared to trans

Mohammed Shafi Shajakhan (1):
      ath9k_hw: Fix enabling of MCI and RTT

Naveen Gangadharan (2):
      ath6kl: Fix firmware crash dump
      ath6kl: Add unicast mgmt frame buffering

Paul Stewart (1):
      mac80211: Don't let regulatory make us deaf

Prasanna Kumar (1):
      ath6kl: add support for AR6003 2048 byte board file

Raja Mani (7):
      ath6kl: Lower SDIO pad drive strength for hw2.1.1 board
      ath6kl: Fix random system lockup
      ath6kl: Restrict memcpy to bounce buffer only for write request
      ath6kl: Add provision to define suspend policy in disconnected state.
      ath6kl: Check wow state before sending control and data pkt
      ath6kl: Maintain the listen interval per VIF specific
      ath6kl: Set optimal listen intvl,bmiss,scan params while going to wow suspend

Rajkumar Manoharan (1):
      ath9k: configure bss info at assoc notification

Stanislav Yakovlev (1):
      net/wireless: ipw2x00: remove unused definitions for regulatory domain

Stanislaw Gruszka (5):
      rt2x00: rt2800usb: move additional txdone into new function
      rt2x00: rt2800usb: rework txdone code
      rt2x00: rt2800usb: rework txstatus code
      rt2x00: rt2800usb: do not check packedid for aggregated frames
      rt2x00: rt2800usb: limit tx queues length

Sujith Manoharan (7):
      ath9k: Fix BTCOEX shutdown
      ath9k: Remove unnecessary initialization
      ath9k: Remove unused variables
      ath9k: Remove 'other' VIF count
      ath9k_hw: Cleanup FastChannelChange
      ath9k: Remove aggregation flags
      ath9k: Fix multi-VIF BSS handling

Thomas Pedersen (1):
      ath6kl: implement hidden ssid

Vasanthakumar Thiagarajan (14):
      ath6kl: Update license header
      ath6kl: Fix missing release of semaphore in ath6kl_stop_txrx()
      ath6kl: Remove bogus non-NULL pointer check
      ath6kl: Make sure to allocate rx buffers after the endpoint connection
      ath6kl: Fix memory leak of rx packets in endpoint 0
      ath6kl: Make foreground scan a deterministic one
      ath6kl: Register driver ht capabilities in wiphy
      ath6kl: Group wiphy initialization into ath6kl_cfg80211_init()
      ath6kl: Initialize netdev hw_features for every interface
      ath6kl: Refactor ath6kl_wmi_control_rx()
      ath6kl: Skip vif index validation in ath6kl_rx() for wmi events
      ath6kl: Defer wiphy and netdev registration till the end of ath6kl_core_init()
      ath6kl: Make sure wiphy is registered before calling regulatory_hint()
      ath6kl: Fix kernel panic while receiving fwlog during boot

Yegor Yefremov (1):
      Documentation: make exists consistent

Yogesh Ashok Powar (15):
      mwifiex: rename long function names to shorter ones
      mwifiex: rearrange switch statement
      mwifiex: merge functions to derive cfp by chan & freq in one
      mwifiex: use usleep_range instead of udelay
      mwifiex: rearrange if and else blocks to avoid extra indentation
      mwifiex: rename fuctions and variables for better readability
      mwifiex: fix checkpatch --strict warnings/errors Part 1
      mwifiex: fix checkpatch --strict warnings/errors Part 2
      mwifiex: fix checkpatch --strict warnings/errors Part 3
      mwifiex: fix checkpatch --strict warnings/errors Part 4
      mwifiex: fix checkpatch --strict warnings/errors Part 5
      mwifiex: fix checkpatch --strict warnings/errors Part 6
      mwifiex: fix checkpatch --strict warnings/errors Part 7
      mwifiex: fix checkpatch --strict warnings/errors Part 8
      mwifiex: fix checkpatch --strict warnings/errors Part 9

 .../networking/mac80211-auth-assoc-deauth.txt      |   99 +++++
 drivers/net/wireless/ath/ath.h                     |   26 +-
 drivers/net/wireless/ath/ath6kl/Makefile           |    3 +-
 drivers/net/wireless/ath/ath6kl/bmi.c              |    7 +-
 drivers/net/wireless/ath/ath6kl/bmi.h              |   24 ++
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |  342 ++++++++++++----
 drivers/net/wireless/ath/ath6kl/cfg80211.h         |    1 +
 drivers/net/wireless/ath/ath6kl/common.h           |    1 +
 drivers/net/wireless/ath/ath6kl/core.c             |  117 +++---
 drivers/net/wireless/ath/ath6kl/core.h             |   64 +++-
 drivers/net/wireless/ath/ath6kl/debug.c            |  325 +++++++++------
 drivers/net/wireless/ath/ath6kl/debug.h            |   10 +-
 drivers/net/wireless/ath/ath6kl/hif-ops.h          |    1 +
 drivers/net/wireless/ath/ath6kl/hif.c              |   12 +-
 drivers/net/wireless/ath/ath6kl/hif.h              |    4 +
 drivers/net/wireless/ath/ath6kl/htc.c              |  202 +++++++---
 drivers/net/wireless/ath/ath6kl/htc.h              |   16 +-
 drivers/net/wireless/ath/ath6kl/init.c             |  210 ++++------
 drivers/net/wireless/ath/ath6kl/main.c             |   72 +++-
 drivers/net/wireless/ath/ath6kl/sdio.c             |   77 +++-
 drivers/net/wireless/ath/ath6kl/target.h           |    2 +
 drivers/net/wireless/ath/ath6kl/testmode.c         |    1 +
 drivers/net/wireless/ath/ath6kl/testmode.h         |    1 +
 drivers/net/wireless/ath/ath6kl/txrx.c             |   72 +++-
 drivers/net/wireless/ath/ath6kl/usb.c              |    1 +
 drivers/net/wireless/ath/ath6kl/wmi.c              |  307 +++++++++------
 drivers/net/wireless/ath/ath6kl/wmi.h              |   23 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |   21 +-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |   50 +--
 drivers/net/wireless/ath/ath9k/ar9002_initvals.h   |    6 -
 drivers/net/wireless/ath/ath9k/ar9002_mac.c        |    5 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.h        |    2 +
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |  302 --------------
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |   25 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   19 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   23 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |    6 +-
 drivers/net/wireless/ath/ath9k/debug.c             |    4 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |    3 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |    1 -
 drivers/net/wireless/ath/ath9k/hw.c                |  136 ++++---
 drivers/net/wireless/ath/ath9k/hw.h                |   16 +-
 drivers/net/wireless/ath/ath9k/init.c              |   16 +-
 drivers/net/wireless/ath/ath9k/mac.c               |   40 +--
 drivers/net/wireless/ath/ath9k/mac.h               |    4 +-
 drivers/net/wireless/ath/ath9k/main.c              |   53 +--
 drivers/net/wireless/ath/ath9k/rc.c                |   12 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    4 +-
 drivers/net/wireless/ath/ath9k/reg.h               |    1 +
 drivers/net/wireless/ath/ath9k/xmit.c              |   33 +-
 drivers/net/wireless/ath/main.c                    |    9 +-
 drivers/net/wireless/b43/b43.h                     |    3 +
 drivers/net/wireless/b43/main.c                    |   59 ++--
 drivers/net/wireless/b43legacy/b43legacy.h         |    3 +
 drivers/net/wireless/b43legacy/main.c              |   33 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |   10 +-
 drivers/net/wireless/ipw2x00/ipw2200.h             |   12 -
 drivers/net/wireless/iwlegacy/common.c             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |   14 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |    5 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   14 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |    2 +
 drivers/net/wireless/iwlwifi/iwl-drv.c             |  430 +++++++++++++++-----
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |    5 +
 drivers/net/wireless/iwlwifi/iwl-fw.h              |   49 ++-
 drivers/net/wireless/iwlwifi/iwl-mac80211.c        |   15 +-
 drivers/net/wireless/iwlwifi/iwl-shared.h          |   20 -
 drivers/net/wireless/iwlwifi/iwl-testmode.c        |   27 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-int.h  |    2 +
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c   |   31 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c   |    4 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |   44 ++-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   40 ++-
 drivers/net/wireless/iwlwifi/iwl-ucode.c           |   39 +-
 drivers/net/wireless/libertas/cfg.c                |   37 --
 drivers/net/wireless/mac80211_hwsim.c              |    3 +-
 drivers/net/wireless/mwifiex/11n.c                 |   82 ++--
 drivers/net/wireless/mwifiex/11n.h                 |   16 +-
 drivers/net/wireless/mwifiex/11n_aggr.c            |   15 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |  211 +++++-----
 drivers/net/wireless/mwifiex/11n_rxreorder.h       |    5 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   90 ++--
 drivers/net/wireless/mwifiex/cfp.c                 |   90 ++---
 drivers/net/wireless/mwifiex/cmdevt.c              |  166 ++++----
 drivers/net/wireless/mwifiex/fw.h                  |    4 +-
 drivers/net/wireless/mwifiex/init.c                |   31 +-
 drivers/net/wireless/mwifiex/join.c                |  173 ++++----
 drivers/net/wireless/mwifiex/main.c                |   49 ++--
 drivers/net/wireless/mwifiex/main.h                |   19 +-
 drivers/net/wireless/mwifiex/pcie.c                |  390 +++++++++---------
 drivers/net/wireless/mwifiex/scan.c                |  354 ++++++++--------
 drivers/net/wireless/mwifiex/sdio.c                |  192 +++++-----
 drivers/net/wireless/mwifiex/sta_cmd.c             |  175 ++++----
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |  353 ++++++++---------
 drivers/net/wireless/mwifiex/sta_event.c           |   41 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |  117 +++---
 drivers/net/wireless/mwifiex/sta_rx.c              |   12 +-
 drivers/net/wireless/mwifiex/sta_tx.c              |   22 +-
 drivers/net/wireless/mwifiex/txrx.c                |   13 +-
 drivers/net/wireless/mwifiex/util.c                |   20 +-
 drivers/net/wireless/mwifiex/wmm.c                 |  162 ++++----
 drivers/net/wireless/rt2x00/rt2800.h               |    7 +
 drivers/net/wireless/rt2x00/rt2800lib.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |   26 ++
 drivers/net/wireless/rt2x00/rt2800usb.c            |  211 ++++++----
 drivers/net/wireless/rt2x00/rt2x00.h               |   10 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |    2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |   12 -
 drivers/net/wireless/rt2x00/rt2x00usb.c            |   21 +-
 include/linux/nl80211.h                            |   10 +
 include/net/cfg80211.h                             |   10 +-
 include/net/mac80211.h                             |   46 +--
 net/mac80211/chan.c                                |   27 ++
 net/mac80211/debugfs.c                             |   81 ----
 net/mac80211/debugfs_netdev.c                      |   71 +++-
 net/mac80211/driver-ops.h                          |   35 --
 net/mac80211/driver-trace.h                        |   45 +--
 net/mac80211/ieee80211_i.h                         |   34 +-
 net/mac80211/main.c                                |    2 -
 net/mac80211/mlme.c                                |  382 ++++++++----------
 net/mac80211/rc80211_minstrel_ht.c                 |   16 +
 net/mac80211/rx.c                                  |   21 +-
 net/mac80211/tx.c                                  |   10 +-
 net/mac80211/wep.c                                 |   21 +-
 net/mac80211/wep.h                                 |    1 -
 net/mac80211/wpa.c                                 |   22 +-
 net/wireless/nl80211.c                             |    8 +
 net/wireless/scan.c                                |    7 +-
 net/wireless/wext-sme.c                            |    3 +
 133 files changed, 4047 insertions(+), 3621 deletions(-)
 create mode 100644 Documentation/networking/mac80211-auth-assoc-deauth.txt
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
