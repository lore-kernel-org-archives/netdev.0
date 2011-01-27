From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2011-01-27
Date: Thu, 27 Jan 2011 16:55:52 -0500
Message-ID: <20110127215552.GD2271@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:32912 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373Ab1A0WAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 17:00:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is the first wireless pull request for the 2.6.39 cycle.

This includes the usual batch of driver updates, with ath5k, ath9k, and
iwlwifi giving their usual strong showings.  Of note, ath9k gets some
benefits from Ben Greear's work with multiple vifs, ath5k (and cfg80211)
gets some support for 802.11j thanks to Bruno Randolf, and iwlwifi gains
support for a new hardware series from Intel.  carl9170, mwl8k, and
rt2x00 get some action as well, as does mac80211.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit b4e69ac670d71b5748dc81e536b2cb103489badd:

  Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6 (2011-01-26 13:49:30 -0800)

are available in the git repository at:

  ssh://master.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Ben Greear (14):
      mac80211: Show max retry-counts in kernel messages.
      ath9k: Fix up hardware mode and beacons with multiple vifs.
      mac80211: Fix skb-copy failure debug message.
      ath9k: Show some live tx-queue values in debugfs.
      ath9k: Initialize ah->hw
      ath9k: Add more information to debugfs xmit file.
      ath9k: Remove un-used member from ath_node.
      ath9k: Ensure xmit makes progress.
      ath9k: Add counters to distinquish AMPDU enqueues.
      ath9k: Keep track of stations for debugfs.
      ath9k: More xmit queue debugfs information.
      ath9k: Restart xmit logic in xmit watchdog.
      ath9k: Add 'misc' file to debugfs, fix queue indexes.
      ath9k: Try more than one queue when scheduling new aggregate.

Bruno Randolf (9):
      cfg80211: Extend channel to frequency mapping for 802.11j
      ath5k: Use mac80211 channel mapping function
      ath5k: Rename ath5k_copy_channels
      ath5k: Add 802.11j 4.9GHz channels to allowed channels
      ath5: Remove unused CTL definitions
      ath5k: Remove unused sc->curmode
      ath5k: Remove redundant sc->curband
      ath5k: Simplify loop when setting up channels
      ath5k: ath5k_setup_channels cleanup and whitespace

Christian Lamparter (3):
      carl9170: update fw/hw headers
      carl9170: enable wake-on-lan feature testing
      carl9170: utilize fw seq counter for mgmt/non-QoS data frames

Felix Fietkau (11):
      ath9k: fix bogus sequence number increases on aggregation tid flush
      ath9k: fix initial sequence number after starting an ampdu session
      ath9k: reinitialize block ack window data when starting aggregation
      ath9k: reduce the likelihood of baseband hang check false positives
      ath9k_hw: partially revert "fix dma descriptor rx error bit parsing"
      ath9k: try more than one tid when scheduling a new aggregate
      ath9k: fix excessive BAR sending when a frame exceeds its retry limit
      mac80211: drop non-auth 3-addr data frames when running as a 4-addr station
      ath9k: remove a bogus error message
      ath9k_hw: replace magic values in register writes with proper defines
      ath9k: fix misplaced debug code

Jay Sternberg (1):
      iwlwifi: correct debugfs data dumped from sram

Joel A Fernandes (1):
      mac80211: Rewrote code for checking if destinations are proxied.

Johannes Berg (11):
      mac80211: don't return beacons when mesh is disabled
      mac80211: track receiver's aggregation reorder buffer size
      mac80211: allow advertising correct maximum aggregate size
      iwlagn: make iwl_rx_handle static
      iwlagn: add support for waiting for notifications
      iwlagn: properly wait for PAN disable
      iwlagn: return error if PAN disable timeout
      iwlwifi: fix 4965 notification wait setup
      iwlwifi: implement remain-on-channel
      iwlwifi: replace minimum slot time constant
      mac80211: use DECLARE_EVENT_CLASS

John W. Linville (1):
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlwifi/iwlwifi-2.6

Luciano Coelho (1):
      mac80211: add hw configuration for max ampdu buffer size

Meenakshi Venkataraman (1):
      iwlagn: Enable idle powersave mode in 1000 series

Mohammed Shafi Shajakhan (1):
      ath9k: clean up enums and unused macros

Nick Ledovskikh (1):
      mac80211:mesh_mpp_table_grow call should depend on MESH_WORK_GROW_MPP_TABLE flag.

Nishant Sarmukadam (4):
      mwl8k: Modify add_dma_header to include pad parameters
      mwl8k: Add encapsulation of data packet for crypto
      mwl8k: Set mac80211 rx status flags appropriately when hw crypto is enabled
      mwl8k: Enable HW encryption for AP mode

RA-Jay Hung (2):
      rt2x00: Fix radio off hang issue for PCIE interface
      rt2x00: Fix and fine-tune rf registers for RT3070/RT3071/RT3090

Rajkumar Manoharan (3):
      ath9k: preserve caldata history buffer across scanning
      ath9k_htc: keep calibrated noise floor value for oper channel
      ath9k_hw: fix carrier leakage calibration for AR9271

Senthil Balasubramanian (2):
      ath9k_hw: Fix incorrect macversion and macrev checks
      ath9k_hw: read and backup AR_WA register value even before chip reset on.

Sujith Manoharan (2):
      ath9k_htc: Add multiple register read API
      ath9k_hw: Offload USB eeprom reading to target

Wey-Yi Guy (11):
      mac80211: mesh only parameter mppath maybe unused
      iwlwifi: use mac80211 throughput trigger
      iwlagn: remove reference to gen2a and gen2b
      iwlagn: add 2000 series EEPROM version
      iwlagn: 2000 series devices support
      iwlagn: add 2000 series pci id
      iwlagn: add 2000 series to Kconfig
      iwlagn: remove Gen2 from Kconfig
      iwlwifi: remove g2 from csr hw rev
      iwlwifi: add hw rev for 2000 series devices
      iwlwifi: initial P2P support

Wojciech Dubowik (1):
      ath5k: Fix return codes for eeprom read functions.

 drivers/net/wireless/ath/ar9170/main.c         |    3 +-
 drivers/net/wireless/ath/ath.h                 |    2 +
 drivers/net/wireless/ath/ath5k/ahb.c           |    7 +-
 drivers/net/wireless/ath/ath5k/base.c          |   95 ++---
 drivers/net/wireless/ath/ath5k/base.h          |    3 -
 drivers/net/wireless/ath/ath5k/eeprom.c        |   24 +-
 drivers/net/wireless/ath/ath5k/eeprom.h        |   28 +--
 drivers/net/wireless/ath/ath5k/pci.c           |    9 +-
 drivers/net/wireless/ath/ath9k/ar9002_calib.c  |    5 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |   24 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c    |    8 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h    |    2 +
 drivers/net/wireless/ath/ath9k/ath9k.h         |   47 ++-
 drivers/net/wireless/ath/ath9k/beacon.c        |   16 +-
 drivers/net/wireless/ath/ath9k/calib.c         |    5 +-
 drivers/net/wireless/ath/ath9k/debug.c         |  279 ++++++++++++-
 drivers/net/wireless/ath/ath9k/debug.h         |   12 +-
 drivers/net/wireless/ath/ath9k/eeprom.c        |   32 ++
 drivers/net/wireless/ath/ath9k/eeprom.h        |    2 +
 drivers/net/wireless/ath/ath9k/eeprom_4k.c     |   41 ++-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c   |   45 ++-
 drivers/net/wireless/ath/ath9k/eeprom_def.c    |   32 ++-
 drivers/net/wireless/ath/ath9k/htc.h           |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c  |   29 ++
 drivers/net/wireless/ath/ath9k/htc_drv_main.c  |    9 +-
 drivers/net/wireless/ath/ath9k/hw.c            |   21 +-
 drivers/net/wireless/ath/ath9k/hw.h            |    3 +
 drivers/net/wireless/ath/ath9k/init.c          |   10 +-
 drivers/net/wireless/ath/ath9k/mac.c           |   14 +-
 drivers/net/wireless/ath/ath9k/main.c          |  336 +++++++++++----
 drivers/net/wireless/ath/ath9k/recv.c          |   16 +-
 drivers/net/wireless/ath/ath9k/virtual.c       |   48 --
 drivers/net/wireless/ath/ath9k/xmit.c          |  164 +++++---
 drivers/net/wireless/ath/carl9170/carl9170.h   |    1 +
 drivers/net/wireless/ath/carl9170/fw.c         |   15 +
 drivers/net/wireless/ath/carl9170/fwcmd.h      |    1 +
 drivers/net/wireless/ath/carl9170/fwdesc.h     |   28 +-
 drivers/net/wireless/ath/carl9170/hw.h         |   25 +
 drivers/net/wireless/ath/carl9170/main.c       |    9 +-
 drivers/net/wireless/ath/carl9170/tx.c         |    3 +
 drivers/net/wireless/ath/carl9170/version.h    |    8 +-
 drivers/net/wireless/ath/carl9170/wlan.h       |   20 +-
 drivers/net/wireless/iwlwifi/Kconfig           |   26 +-
 drivers/net/wireless/iwlwifi/Makefile          |    1 +
 drivers/net/wireless/iwlwifi/iwl-1000.c        |    1 +
 drivers/net/wireless/iwlwifi/iwl-2000.c        |  556 ++++++++++++++++++++++++
 drivers/net/wireless/iwlwifi/iwl-3945-led.c    |   27 --
 drivers/net/wireless/iwlwifi/iwl-3945.c        |    5 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c        |    5 +
 drivers/net/wireless/iwlwifi/iwl-6000.c        |   52 ++--
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c    |   18 +-
 drivers/net/wireless/iwlwifi/iwl-agn-led.c     |   14 +-
 drivers/net/wireless/iwlwifi/iwl-agn-led.h     |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c     |   51 ++-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c    |   38 ++-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c      |    9 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c         |  177 ++++++++-
 drivers/net/wireless/iwlwifi/iwl-agn.h         |   30 ++-
 drivers/net/wireless/iwlwifi/iwl-commands.h    |    6 +
 drivers/net/wireless/iwlwifi/iwl-core.c        |   10 +-
 drivers/net/wireless/iwlwifi/iwl-core.h        |   14 -
 drivers/net/wireless/iwlwifi/iwl-csr.h         |   14 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c     |  106 +++---
 drivers/net/wireless/iwlwifi/iwl-dev.h         |   57 ++-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h      |   26 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c        |    1 +
 drivers/net/wireless/iwlwifi/iwl-led.c         |  201 ++++-----
 drivers/net/wireless/iwlwifi/iwl-led.h         |   16 +-
 drivers/net/wireless/iwlwifi/iwl-legacy.c      |    4 -
 drivers/net/wireless/iwlwifi/iwl3945-base.c    |    8 +-
 drivers/net/wireless/iwmc3200wifi/cfg80211.c   |    3 +-
 drivers/net/wireless/iwmc3200wifi/rx.c         |    7 +-
 drivers/net/wireless/libertas/cfg.c            |    6 +-
 drivers/net/wireless/mac80211_hwsim.c          |    3 +-
 drivers/net/wireless/mwl8k.c                   |  456 +++++++++++++++++++-
 drivers/net/wireless/rt2x00/rt2800.h           |    6 +
 drivers/net/wireless/rt2x00/rt2800lib.c        |   34 +-
 drivers/net/wireless/rt2x00/rt2800lib.h        |    3 +-
 drivers/net/wireless/rt2x00/rt2800pci.c        |   36 +--
 drivers/net/wireless/rt2x00/rt2x00dev.c        |    5 +-
 drivers/net/wireless/rtlwifi/core.c            |    3 +-
 drivers/net/wireless/wl1251/rx.c               |    3 +-
 drivers/net/wireless/wl12xx/rx.c               |    2 +-
 include/net/cfg80211.h                         |    3 +-
 include/net/mac80211.h                         |   20 +-
 net/mac80211/agg-rx.c                          |    7 +-
 net/mac80211/agg-tx.c                          |   23 +-
 net/mac80211/driver-ops.h                      |    6 +-
 net/mac80211/driver-trace.h                    |  213 ++--------
 net/mac80211/ibss.c                            |    3 +-
 net/mac80211/main.c                            |    1 +
 net/mac80211/mesh.c                            |    4 +-
 net/mac80211/mlme.c                            |   16 +-
 net/mac80211/rx.c                              |   27 +-
 net/mac80211/scan.c                            |    3 +-
 net/mac80211/sta_info.h                        |    2 +
 net/mac80211/tx.c                              |   17 +-
 net/wireless/reg.c                             |    6 +-
 net/wireless/util.c                            |   36 +-
 net/wireless/wext-compat.c                     |    5 +-
 100 files changed, 2886 insertions(+), 1030 deletions(-)
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-2000.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2011-01-27.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
