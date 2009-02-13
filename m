From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2009-02-13
Date: Fri, 13 Feb 2009 15:46:07 -0500
Message-ID: <20090213204607.GH3581@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is another round of wireless updates intended for 2.6.30.  Along
with the usual driver updates there is some orinoco reorganization and
cleanup from David Kilroy and a passel of mac80211 updates and cleanups
from Johannes Berg.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6/

---

The following changes since commit 367681f4ec9b226db201f181c4f47dd973f7=
33a6:
  Breno Leit=E3o (1):
        ixgbe: Removing the unused PAGE_USE_COUNT() macro.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Alina Friedrichsen (1):
      mac80211: Remove TSF atomic requirement from the documentation

David Kilroy (16):
      orinoco: address leading and trailing whitespace
      orinoco: spaces in parenthesised expressions
      orinoco: remove unnecessary braces
      orinoco: keep line length below 80 characters
      orinoco: Fix interesting checkpatch errors
      orinoco: Rename orinoco.c
      orinoco: use orinoco_private instead of net_device in scan helper
      orinoco: Move scan helpers to a separate file
      orinoco: Move MIC helpers into new file
      orinoco: Move firmware handling into a separate file
      orinoco: Use accessor functions for bitrate tables
      orinoco: Add hardware function to set multicast mode
      orinoco: Move hardware functions into separate file
      orinoco: Move WEXT handlers into a separate file
      orinoco: hermes_dld does not need to be a module
      orinoco: hermes doesn't need to be a separate module

Johannes Berg (27):
      zd1211rw: do not ratelimit no-ops
      mac80211: disable IBSS beacon before join
      zd1211rw: honour enable_beacon conf
      mac80211: properly validate/translate IW_AUTH_MFP values
      mac80211: reject extra IEs for probe request when hw_scan
      mac80211: fix beacon enable more
      mac80211: remove bssid argument from prepare_for_handlers
      mac80211: remove stray aggregation debugfs definition
      mac80211: fix RX aggregation timeouts
      mac80211: restructure HT code
      mac80211: restrict aggregation to supported interface modes
      mac80211: hardware should not deny going back to legacy
      mac80211: document TX aggregation (and small cleanup)
      mac80211: fix race in TX aggregation
      mac80211: fix aggregation timer lockups
      mac80211: clean up BA session teardown
      mac80211: RX aggregation: clean up stop session
      mac80211: further cleanups to stopping BA sessions
      cfg80211/nl80211: scanning (and mac80211 update to use it)
      mac80211: dont add BSS when creating IBSS
      cfg80211: free_priv for BSS info
      cfg80211: allow users to request removing a BSS
      cfg80211: add more flexible BSS lookup
      mac80211: use cfg80211s BSS infrastructure
      mac80211: calculate wstats_flags on the fly
      mac80211: fix IBSS auth
      mac80211: split managed/ibss code a little more

Kalle Valo (2):
      mac80211: remove multicast check from check_tim()
      mac80211: use ps-poll when dynamic power save mode is disabled

Luis R. Rodriguez (2):
      ath9k: add comments for ath9k_hw_configpcipowersave()
      ath9k: add udelay() for AR5416 on ath9k_hw_configpcipowersave()

Michael Buesch (1):
      b43: Add parts of LP-PHY TX power control

Nick Kossifidis (7):
      ath5k: PHY code cleanup
      ath5k: Update gain_F calibration code and add documentation
      ath5k: Update RF Buffer handling
      ath5k: Update initvals
      ath5k: Update reset code
      ath5k: Disable BMISS interrupts
      ath5k: Don't call reset on config_interface

Reinette Chatre (1):
      iwlwifi: fix FAT channel config for 5000 series

Sujith (14):
      ath9k: Lock mac80211 callbacks with a mutex
      ath9k: Remove all the redundant internal buffer types
      ath9k: Handle mac80211's FIF_CONTROL flag properly
      ath9k: Add retry counters to rate control debug file
      ath9k: Header file cleanup
      ath9k: Convert ANI channel to a pointer
      ath9k: Remove all the sc_ prefixes
      ath9k: Store HW version information in a separate structure
      ath9k: Move regulatory information to a separate structure
      ath9k: Remove duplicate variables
      ath9k: Merge ath_hal and ath_hal_5416 structures
      ath9k: Add callbacks hooks for EEPROM operations
      ath9k: Cleanup EEPROM operations
      ath9k: Remove all the useless ah_ variable prefixes

Tobias Klauser (2):
      ath5k: Storage class should be before const qualifier
      orinoco: Storage class should be before const qualifier

Tomas Winkler (2):
      iwlwifi: use pci registers defined in pci_regs.h
      iwlwifi: drop PCIe workaround applicable for development boards

Vasanthakumar Thiagarajan (1):
      mac80211: Free current bss information in few places where we don=
't need it any more

Vivek Natarajan (1):
      mac80211: Fix the wrong WARN_ON message appearing on enabling pow=
er save.

 drivers/net/wireless/ath5k/ath5k.h          |   73 +-
 drivers/net/wireless/ath5k/attach.c         |   18 +-
 drivers/net/wireless/ath5k/base.c           |   15 +-
 drivers/net/wireless/ath5k/eeprom.c         |   18 +-
 drivers/net/wireless/ath5k/eeprom.h         |    1 +
 drivers/net/wireless/ath5k/initvals.c       | 1575 +++----
 drivers/net/wireless/ath5k/phy.c            | 2029 +++-------
 drivers/net/wireless/ath5k/reg.h            |  124 +-
 drivers/net/wireless/ath5k/reset.c          |  948 +++--
 drivers/net/wireless/ath5k/rfbuffer.h       | 1181 +++++
 drivers/net/wireless/ath5k/rfgain.h         |  516 +++
 drivers/net/wireless/ath9k/ahb.c            |   16 +-
 drivers/net/wireless/ath9k/ani.c            |  263 +-
 drivers/net/wireless/ath9k/ani.h            |  138 +
 drivers/net/wireless/ath9k/ath9k.h          | 1640 +++-----
 drivers/net/wireless/ath9k/beacon.c         |   96 +-
 drivers/net/wireless/ath9k/calib.c          |  190 +-
 drivers/net/wireless/ath9k/calib.h          |  124 +
 drivers/net/wireless/ath9k/core.h           |  816 ----
 drivers/net/wireless/ath9k/debug.c          |  149 +-
 drivers/net/wireless/ath9k/debug.h          |  153 +
 drivers/net/wireless/ath9k/eeprom.c         | 2922 +++++++-------
 drivers/net/wireless/ath9k/eeprom.h         |  473 ++
 drivers/net/wireless/ath9k/hw.c             | 1181 +++---
 drivers/net/wireless/ath9k/hw.h             | 1568 +++-----
 drivers/net/wireless/ath9k/mac.c            |  175 +-
 drivers/net/wireless/ath9k/mac.h            |  676 +++
 drivers/net/wireless/ath9k/main.c           |  479 ++-
 drivers/net/wireless/ath9k/pci.c            |   20 +-
 drivers/net/wireless/ath9k/phy.c            |  221 +-
 drivers/net/wireless/ath9k/phy.h            |   14 +-
 drivers/net/wireless/ath9k/rc.c             |   16 +-
 drivers/net/wireless/ath9k/rc.h             |   17 +-
 drivers/net/wireless/ath9k/recv.c           |   51 +-
 drivers/net/wireless/ath9k/reg.h            |   53 +-
 drivers/net/wireless/ath9k/regd.c           |   70 +-
 drivers/net/wireless/ath9k/regd.h           |   26 +-
 drivers/net/wireless/ath9k/xmit.c           |   51 +-
 drivers/net/wireless/b43/b43.h              |    3 +
 drivers/net/wireless/b43/phy_lp.c           |  177 +-
 drivers/net/wireless/b43/phy_lp.h           |   16 +-
 drivers/net/wireless/b43/tables_lpphy.c     |   61 +
 drivers/net/wireless/b43/tables_lpphy.h     |    8 +
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h  |    6 -
 drivers/net/wireless/iwlwifi/iwl-3945.c     |   23 +-
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h  |    7 -
 drivers/net/wireless/iwlwifi/iwl-4965.c     |   21 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c     |   13 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c      |   18 +-
 drivers/net/wireless/iwlwifi/iwl-core.c     |    1 +
 drivers/net/wireless/iwlwifi/iwl-core.h     |    8 +
 drivers/net/wireless/iwlwifi/iwl-eeprom.c   |    8 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h   |    2 +
 drivers/net/wireless/iwlwifi/iwl-power.c    |    6 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   17 +-
 drivers/net/wireless/orinoco/Makefile       |    3 +-
 drivers/net/wireless/orinoco/airport.c      |    2 +-
 drivers/net/wireless/orinoco/fw.c           |  340 ++
 drivers/net/wireless/orinoco/fw.h           |   16 +
 drivers/net/wireless/orinoco/hermes.c       |   18 -
 drivers/net/wireless/orinoco/hermes_dld.c   |   33 +-
 drivers/net/wireless/orinoco/hw.c           |  586 +++
 drivers/net/wireless/orinoco/hw.h           |   47 +
 drivers/net/wireless/orinoco/main.c         | 2654 ++++++++++++
 drivers/net/wireless/orinoco/main.h         |   63 +
 drivers/net/wireless/orinoco/mic.c          |   79 +
 drivers/net/wireless/orinoco/mic.h          |   22 +
 drivers/net/wireless/orinoco/orinoco.c      | 6153 -------------------=
--------
 drivers/net/wireless/orinoco/orinoco_cs.c   |    2 +-
 drivers/net/wireless/orinoco/orinoco_pci.h  |    2 +-
 drivers/net/wireless/orinoco/orinoco_tmd.c  |    2 +-
 drivers/net/wireless/orinoco/scan.c         |  233 +
 drivers/net/wireless/orinoco/scan.h         |   29 +
 drivers/net/wireless/orinoco/spectrum_cs.c  |    4 +-
 drivers/net/wireless/orinoco/wext.c         | 2325 ++++++++++
 drivers/net/wireless/orinoco/wext.h         |   13 +
 drivers/net/wireless/zd1211rw/zd_def.h      |    5 +
 drivers/net/wireless/zd1211rw/zd_mac.c      |   23 +-
 include/linux/nl80211.h                     |   65 +
 include/net/cfg80211.h                      |  154 +
 include/net/mac80211.h                      |   10 +-
 include/net/wireless.h                      |    3 +
 net/mac80211/Makefile                       |    2 +-
 net/mac80211/agg-rx.c                       |  302 ++
 net/mac80211/agg-tx.c                       |  636 +++
 net/mac80211/cfg.c                          |   31 +-
 net/mac80211/ht.c                           |  869 +----
 net/mac80211/ieee80211_i.h                  |   81 +-
 net/mac80211/iface.c                        |    5 +-
 net/mac80211/main.c                         |   48 +-
 net/mac80211/mesh.c                         |   10 -
 net/mac80211/mesh.h                         |    1 -
 net/mac80211/mesh_hwmp.c                    |    1 -
 net/mac80211/mlme.c                         |  703 ++--
 net/mac80211/rx.c                           |   68 +-
 net/mac80211/scan.c                         |  620 +---
 net/mac80211/spectmgmt.c                    |    7 +-
 net/mac80211/sta_info.c                     |   37 +-
 net/mac80211/sta_info.h                     |    4 +-
 net/mac80211/tx.c                           |    8 +-
 net/mac80211/wext.c                         |   98 +-
 net/wireless/Makefile                       |    2 +-
 net/wireless/core.c                         |    8 +
 net/wireless/core.h                         |   20 +
 net/wireless/nl80211.c                      |  323 ++
 net/wireless/nl80211.h                      |    8 +
 net/wireless/scan.c                         |  836 ++++
 108 files changed, 19259 insertions(+), 16848 deletions(-)
 create mode 100644 drivers/net/wireless/ath5k/rfbuffer.h
 create mode 100644 drivers/net/wireless/ath5k/rfgain.h
 create mode 100644 drivers/net/wireless/ath9k/ani.h
 create mode 100644 drivers/net/wireless/ath9k/calib.h
 delete mode 100644 drivers/net/wireless/ath9k/core.h
 create mode 100644 drivers/net/wireless/ath9k/debug.h
 create mode 100644 drivers/net/wireless/ath9k/eeprom.h
 create mode 100644 drivers/net/wireless/ath9k/mac.h
 create mode 100644 drivers/net/wireless/orinoco/fw.c
 create mode 100644 drivers/net/wireless/orinoco/fw.h
 create mode 100644 drivers/net/wireless/orinoco/hw.c
 create mode 100644 drivers/net/wireless/orinoco/hw.h
 create mode 100644 drivers/net/wireless/orinoco/main.c
 create mode 100644 drivers/net/wireless/orinoco/main.h
 create mode 100644 drivers/net/wireless/orinoco/mic.c
 create mode 100644 drivers/net/wireless/orinoco/mic.h
 delete mode 100644 drivers/net/wireless/orinoco/orinoco.c
 create mode 100644 drivers/net/wireless/orinoco/scan.c
 create mode 100644 drivers/net/wireless/orinoco/scan.h
 create mode 100644 drivers/net/wireless/orinoco/wext.c
 create mode 100644 drivers/net/wireless/orinoco/wext.h
 create mode 100644 net/mac80211/agg-rx.c
 create mode 100644 net/mac80211/agg-tx.c
 create mode 100644 net/wireless/scan.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2009-02-13.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
