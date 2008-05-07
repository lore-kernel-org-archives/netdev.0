From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2008-05-07
Date: Wed, 7 May 2008 16:30:11 -0400
Message-ID: <20080507203011.GA22533@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2873 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755867AbYEGU7H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2008 16:59:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Here is the first batch of wireless patches to queue for net-next-2.6.
The biggest chunk of them are iwlwifi updates, including support for
the latest round of Intel wireless hardware.  The b43 and rt2x00 drivers
have some big updates as well, along with a few other patches.

Please let me know if there is a problem!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit a7ca0268b5dfffcaa8a1fe40c6eccdeac50fa3ea:
  Allan Stephens (1):
        tipc: Update version number to TIPC 1.6.4

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Adrian Bunk (3):
      make sta_rx_agg_session_timer_expired() static
      remove ieee80211_tx_frame()
      remove ieee80211_wx_{get,set}_auth()

Emmanuel Grumbach (12):
      iwlwifi: HW dependent run time calibration
      iwlwifi: HW crypto acceleration fixes
      iwlwifi: remove uneeded callback
      iwlwifi: CT-Kill configuration fix
      iwlwifi: HT IE in probe request clean up
      iwlwifi: clean up register names and defines
      iwlwifi: move Flow Handlers define to iwl-fh.h
      iwlwifi: move verify_ucode functions to iwl-core
      iwlwifi: move hw_rx_handler_setup to iwl-4965.c
      iwlwifi-5000: update the CT-Kill value for 5000 series
      iwlwifi-5000: add run time calibrations for 5000
      iwlwifi-5000: update the byte count in SCD

Ester Kummer (1):
      mac80211: correct skb allocation

Guy Cohen (8):
      iwlwifi: remove support for Narrow Channel (10Mhz)
      iwlwifi: HT antenna/chains overhaul
      iwlwifi: TLC modifications
      iwlwifi: rate scale module cleanups
      iwlwifi: rate scale restructure toggle_antenna functions
      iwlwifi: rs fix wrong parenthesizing in rs_get_lower_rate function
      iwlwifi: rate sacaling fixes
      iwlwifi: more RS improvements

Holger Schurig (3):
      libertas: debug output tweaks for lbs_thread
      libertas: make some functions void
      libertas: allow removal of card at any time

Ivo van Doorn (9):
      mac80211: Replace ieee80211_tx_control->key_idx with ieee80211_key_conf
      mac80211: Add IEEE80211_KEY_FLAG_PAIRWISE
      rt2x00: Support hardware RTS and CTS-to-self frames
      rt2x00: Remove DRIVER_SUPPORT_MIXED_INTERFACES
      rt2x00: Use rt2x00 queue numbering
      rt2x00: Add helper macros
      rt2x00: Fix kernel-doc
      rt2x00: Release rt2x00 2.1.5
      rt2x00: Clarify supported chipsets in Kconfig

Johannes Berg (5):
      mac80211: a few code cleanups
      mac80211: clean up get_tx_stats callback
      mac80211: remove queue info from ieee80211_tx_status
      mac80211: QoS related cleanups
      mac80211: fix wme code

John W. Linville (1):
      wireless: fix warning introduced by "mac80211: QoS related cleanups"

Larry.Finger@lwfinger.net (1):
      ssb: Allow reading of 440-byte SPROM that is not rev 4

Michael Buesch (3):
      b43: Rewrite LO calibration algorithm
      b43: Remove some dead code
      b43: Don't disable IRQs in mac_suspend

Mohamed Abbas (1):
      iwlwifi: Add power level support

Ron Rindjunsky (7):
      iwlwifi: arranging aggregation actions
      iwlwifi: expanding HW parameters control
      iwlwifi: support 64 bit DMA masks
      iwlwifi: handle shared memory
      iwlwifi: unify init driver flow
      iwlwifi: iwl-sta redundant includes clean up
      iwlwifi-5000: add iwl 5000 shared memory handlers

Tomas Winkler (26):
      iwlwifi: move find station to iwl-sta.c
      iwlwifi: cleanup set_pwr_src
      iwlwifi: define ANA_PLL values in iwl-csr.h
      iwlwifi: export int iwl4965_set_pwr_src
      iwlwifi: changing EEPROM layout handling
      iwlwifi: remove includes to net/ieee80211.h
      iwlwifi: add apm init handler
      iwlwifi: add iwl_hw_detect function to iwl core
      iwlwifi: check eeprom version in pci probe time
      iwlwifi: reorganize TX RX constatns
      iwlwifi: 3945 remove unused SCD definitions
      iwlwifi: remove 49 prefix from general CSR values
      iwlwifi: remove unnecessary apmg settings
      iwlwifi: wrapping nic configuration in iwl core handler
      iwlwifi-5000: adding initial recognition for the 5000 family
      iwlwifi-5000: add ops infrastructure for 5000
      iwlwifi-5000: add apm_init handler for 5000 HW family
      iwlwifi-5000: use iwl4965_set_pwr_src in 5000
      iwlwifi-5000: EEPROM settings for 5000
      iwlwifi-5000: adding iwl5000 HW parameters
      iwlwifi-5000: adjust antennas names in 5000 HW family
      iwlwifi-5000: Add HW REV of 5000 HW family
      iwlwifi-5000: add eeprom check version handler
      iwlwifi-5000: add nic config handler for 5000 HW
      iwlwifi: rename iwl-4965-commands to iwl-commands.h
      iwlwifi: rename iwl-4965.h to iwl-dev.h

 drivers/net/wireless/adm8211.c                     |    7 +-
 drivers/net/wireless/ath5k/base.c                  |   10 +-
 drivers/net/wireless/ath5k/base.h                  |    3 +-
 drivers/net/wireless/b43/b43.h                     |    3 +-
 drivers/net/wireless/b43/debugfs.c                 |   77 +-
 drivers/net/wireless/b43/debugfs.h                 |    1 +
 drivers/net/wireless/b43/dma.c                     |    8 +-
 drivers/net/wireless/b43/lo.c                      |  727 +++------
 drivers/net/wireless/b43/lo.h                      |  115 +-
 drivers/net/wireless/b43/main.c                    |   42 +-
 drivers/net/wireless/b43/main.h                    |    3 +
 drivers/net/wireless/b43/phy.c                     |  240 +---
 drivers/net/wireless/b43/phy.h                     |   16 +-
 drivers/net/wireless/b43/pio.c                     |    8 +-
 drivers/net/wireless/b43/xmit.c                    |    2 +-
 drivers/net/wireless/b43legacy/dma.c               |    8 +-
 drivers/net/wireless/b43legacy/main.c              |    3 +-
 drivers/net/wireless/b43legacy/pio.c               |    8 +-
 drivers/net/wireless/b43legacy/xmit.c              |    2 +-
 drivers/net/wireless/iwlwifi/Kconfig               |   36 +-
 drivers/net/wireless/iwlwifi/Makefile              |    8 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h         |   13 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c         |    1 -
 drivers/net/wireless/iwlwifi/iwl-3945.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h            |    5 -
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h         |  605 +-------
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c         |  983 ++++++------
 drivers/net/wireless/iwlwifi/iwl-4965-rs.h         |   87 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c            | 1667 +++++---------------
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h         |  133 ++
 drivers/net/wireless/iwlwifi/iwl-5000.c            |  519 ++++++
 drivers/net/wireless/iwlwifi/iwl-calib.c           |  779 +++++++++
 drivers/net/wireless/iwlwifi/iwl-calib.h           |  104 ++
 .../{iwl-4965-commands.h => iwl-commands.h}        |   63 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |  562 +++++++-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   34 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |   32 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |    2 +-
 .../net/wireless/iwlwifi/{iwl-4965.h => iwl-dev.h} |  180 ++--
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |  118 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |  205 ++--
 drivers/net/wireless/iwlwifi/iwl-fh.h              |  391 +++++
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-led.c             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-power.c           |  423 +++++
 drivers/net/wireless/iwlwifi/iwl-power.h           |   76 +
 drivers/net/wireless/iwlwifi/iwl-prph.h            |  310 ++++-
 drivers/net/wireless/iwlwifi/iwl-rfkill.c          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c             |   92 +-
 drivers/net/wireless/iwlwifi/iwl-sta.h             |   11 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |   21 +-
 drivers/net/wireless/iwlwifi/iwl4965-base.c        | 1014 +++----------
 drivers/net/wireless/libertas/cmd.h                |    2 +-
 drivers/net/wireless/libertas/decl.h               |    4 +-
 drivers/net/wireless/libertas/main.c               |   26 +-
 drivers/net/wireless/p54/p54.h                     |    2 +-
 drivers/net/wireless/p54/p54common.c               |   28 +-
 drivers/net/wireless/rt2x00/Kconfig                |   55 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |   37 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |   35 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |   20 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |   20 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |    6 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   39 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00pci.h            |    6 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |    6 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |   37 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h            |   21 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |   27 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |   33 +-
 drivers/ssb/pci.c                                  |   20 +-
 include/net/ieee80211.h                            |   11 -
 include/net/mac80211.h                             |  105 +-
 net/ieee80211/ieee80211_tx.c                       |   86 -
 net/ieee80211/ieee80211_wx.c                       |   89 --
 net/mac80211/aes_ccm.c                             |    2 +-
 net/mac80211/aes_ccm.h                             |    2 +-
 net/mac80211/debugfs.c                             |   43 -
 net/mac80211/debugfs_netdev.c                      |    2 +-
 net/mac80211/debugfs_sta.c                         |   38 -
 net/mac80211/ieee80211_i.h                         |   15 +-
 net/mac80211/iface.c                               |    3 +-
 net/mac80211/key.c                                 |    7 +
 net/mac80211/main.c                                |   11 +-
 net/mac80211/mlme.c                                |   68 +-
 net/mac80211/rx.c                                  |    5 -
 net/mac80211/sta_info.c                            |    2 +-
 net/mac80211/tkip.h                                |    4 +-
 net/mac80211/wep.c                                 |    2 +-
 net/mac80211/wep.h                                 |    2 +-
 net/mac80211/wme.c                                 |  119 +-
 net/mac80211/wpa.c                                 |    8 +-
 94 files changed, 5748 insertions(+), 5071 deletions(-)
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-5000-hw.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-5000.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-calib.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-calib.h
 rename drivers/net/wireless/iwlwifi/{iwl-4965-commands.h => iwl-commands.h} (98%)
 rename drivers/net/wireless/iwlwifi/{iwl-4965.h => iwl-dev.h} (91%)
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-fh.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-power.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-power.h

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2008-05-07.patch.gz

-- 
John W. Linville
linville@tuxdriver.com
