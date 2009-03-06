From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2009-03-06
Date: Fri, 6 Mar 2009 16:34:23 -0500
Message-ID: <20090306213422.GH3712@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is the latest round of wireless bits intended for -next.  It is
mostly driver bits this time around -- Johannes is somewhere on skis...

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 508827ff0ac3981d420edac64a70de7f4e304d38:
  David S. Miller (1):
        Merge branch 'master' of master.kernel.org:/.../davem/net-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Abhijeet Kolekar (4):
      iwl3945: synchronize timestamp with uCode
      iwl3945: unify set key flow with iwlwifi
      iwl3945: add iwl3945_setup_mac
      iwl3945 : use iwl_activate_qos

Alina Friedrichsen (4):
      zd1211rw: Implement get_tsf()
      ath9k: Fix FIF_BCN_PRBRESP_PROMISC handling
      ath9k: Set TSF fix
      ath5k: Set TSF fix

Frank Seidel (2):
      airo: reduce stack memory footprint
      iwlwifi: reduce stack size

Gabor Juhos (1):
      ath9k: fix AR_TXCFG_DMASZ_MASK value

Ivo van Doorn (2):
      rt2x00: Fix SW antenna diversity
      rt2x00: Export all register stats through debugfs

Jay Sternberg (1):
      iwlwifi: update 5150 API version to support new firmware

Jiri Slaby (1):
      ath5k: fix hw rate index condition

Johannes Berg (1):
      mac80211: Fix quality reporting for wireless stats

Jouni Malinen (20):
      ath9k: Add module parameter to disable hardware crypto
      ath9k: Fix hw crypto configuration for TKIP in AP mode
      ath9k: Document keycache operations
      ath9k: Remove unused key xoring
      ath9k: Clean up setkey operations
      ath9k: Cleanup multiple VIF processing
      ath9k: Set BSSID mask based on configured interfaces
      ath9k: Add data structure for supporting virtual radio/wiphy operation
      ath9k: Add support for multiple secondary virtual wiphys
      ath9k: Configure RX filter for multi-BSSID broadcast
      ath9k: Virtual wiphy pause/unpause functionality
      ath9k: Add routines for switching between active virtual wiphys
      ath9k: Make start/stop operations aware of virtual wiphys
      ath9k: Register larger listen interval
      ath9k: Pause other virtual wiphys on channel change
      ath9k: Check virtual wiphy state on tx()
      ath9k: Add workaround to recover from failed channel changes
      ath9k: Special processing for channel changes during scan
      ath9k: Add a simple virtual wiphy scheduler
      ath9k: Add a debugfs interface for controlling virtual wiphys

Michael Buesch (3):
      ssb: Add SPROM fallback support
      b43: Pass more RX flags to mac80211
      b43: Fix compilation for devices without PCI core

Reinette Chatre (1):
      iwlwifi: fix *pci_probe error flow

Roel Kluin (1):
      wireless, wavelan: spin off by 1

Sujith (11):
      mac80211: Notify the driver only when the beacon interval changes
      mac80211: Fix TKIP/WEP HT capability handling
      ath9k: Fill in rate_update mac80211 callback
      mac80211: Update IBSS beacon timestamp properly
      ath9k: Use new scan notifiers from mac80211
      ath9k: Scrub beacon.c
      ath9k: Cleanup beacon stuck processing
      ath9k: Split beacon configuration into mode specific routines
      ath9k: Handle TSF properly for AP mode
      ath9k: Lock config_interface() callback with a mutex
      ath9k: Remove unused variables in struct ath_beacon_config

Vasanthakumar Thiagarajan (2):
      ath9k: Configure Power control register appropriately for h/w with 4k eeprom
      ath9k: Remove ununsed ack duration stuff with long/short preamble

Vivek Natarajan (2):
      mac80211: Always send a null data frame if TIM bit is set.
      ath9k: Handle power modes in isr for power save.

 drivers/net/wireless/airo.c                 |    7 +-
 drivers/net/wireless/ath5k/base.c           |    3 +-
 drivers/net/wireless/ath5k/pcu.c            |    3 +-
 drivers/net/wireless/ath9k/Makefile         |    1 +
 drivers/net/wireless/ath9k/ahb.c            |   12 +-
 drivers/net/wireless/ath9k/ath9k.h          |  127 ++++--
 drivers/net/wireless/ath9k/beacon.c         |  700 +++++++++++----------------
 drivers/net/wireless/ath9k/debug.c          |  164 +++++++
 drivers/net/wireless/ath9k/debug.h          |    1 +
 drivers/net/wireless/ath9k/eeprom.c         |    3 +-
 drivers/net/wireless/ath9k/hw.c             |   94 +++-
 drivers/net/wireless/ath9k/hw.h             |    2 +-
 drivers/net/wireless/ath9k/mac.h            |    9 +-
 drivers/net/wireless/ath9k/main.c           |  405 +++++++++++-----
 drivers/net/wireless/ath9k/pci.c            |   19 +-
 drivers/net/wireless/ath9k/phy.h            |    2 -
 drivers/net/wireless/ath9k/rc.c             |  151 ++++---
 drivers/net/wireless/ath9k/rc.h             |   10 +-
 drivers/net/wireless/ath9k/recv.c           |   60 +++-
 drivers/net/wireless/ath9k/reg.h            |    2 +-
 drivers/net/wireless/ath9k/regd.c           |    6 +-
 drivers/net/wireless/ath9k/virtual.c        |  662 +++++++++++++++++++++++++
 drivers/net/wireless/ath9k/xmit.c           |   29 +-
 drivers/net/wireless/b43/b43.h              |    3 -
 drivers/net/wireless/b43/dma.c              |    1 -
 drivers/net/wireless/b43/main.c             |    2 +
 drivers/net/wireless/b43/xmit.c             |   17 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c  |   11 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c   |   23 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c      |   36 +--
 drivers/net/wireless/iwlwifi/iwl-core.c     |   33 ++
 drivers/net/wireless/iwlwifi/iwl-core.h     |    1 +
 drivers/net/wireless/iwlwifi/iwl-sta.c      |    3 +-
 drivers/net/wireless/iwlwifi/iwl-sta.h      |    1 +
 drivers/net/wireless/iwlwifi/iwl3945-base.c |  319 +++++++------
 drivers/net/wireless/rt2x00/rt2x00debug.c   |   33 +-
 drivers/net/wireless/rt2x00/rt2x00link.c    |   20 +-
 drivers/net/wireless/wavelan_cs.c           |    5 +-
 drivers/net/wireless/zd1211rw/zd_chip.c     |   21 +
 drivers/net/wireless/zd1211rw/zd_chip.h     |    2 +
 drivers/net/wireless/zd1211rw/zd_mac.c      |    7 +
 drivers/ssb/pci.c                           |   14 +-
 drivers/ssb/sprom.c                         |   36 ++
 drivers/ssb/ssb_private.h                   |    1 +
 include/linux/ssb/ssb.h                     |    4 +
 net/mac80211/cfg.c                          |    3 +-
 net/mac80211/ibss.c                         |    8 +-
 net/mac80211/mlme.c                         |    6 +-
 net/mac80211/wext.c                         |   58 ++-
 50 files changed, 2233 insertions(+), 909 deletions(-)
 create mode 100644 drivers/net/wireless/ath9k/virtual.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2009-03-06.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
