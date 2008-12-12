From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2008-12-12
Date: Fri, 12 Dec 2008 15:08:06 -0500
Message-ID: <20081212200806.GA3768@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is another batch of wireless updates intended for 2.6.29.  As
usual, mostly driver updates with a smattering of mac80211 bits as well.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 7a3c66e2d322c638e9306e739d96b2192dacde88:
  Daniel Silverstone (1):
        net: Add support for the KS8695 ethernet devices.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Abbas, Mohamed (1):
      iwl3945: Fix rate scale for B-mode connection

Anna Neal (1):
      libertas: Create sysfs entry for changing the mesh probe response limit

Bob Copeland (1):
      ath5k: fix endianness of bitwise ops when installing mic

Christian Lamparter (4):
      p54usb: rewriting rx/tx routines to make use of usb_anchor's facilities
      mac80211: integrate sta_notify_ps cmds into sta_notify
      p54: enforce strict tx_queue limits
      p54: fix oops on faulty devices

David Kilroy (3):
      orinoco: Fix function names used in debug strings
      orinoco: Fix inappropriate use of IRQ_BAP
      spectrum_cs: Fix function names used in debug strings

Halperin, Daniel C (1):
      iwlwifi: implement iwl_debug_report_frame for iwlagn

Helmut Schaa (1):
      ipw2200: fix scanning while associated

Johannes Berg (7):
      mac80211: improve sta_notify documentation
      cfg80211: fix nl80211 frequency handling
      mac80211: only create default STA interface if supported
      ath9k: remove fragmentation workaround again
      mac80211: remove fragmentation offload functionality
      mac80211/cfg80211: check endianness in sparse runs
      rfkill: strip pointless notifier chain

John W. Linville (1):
      ieee80211_security: correct warning about width of auth_mode

Jouni Malinen (4):
      ath9k: Free Beacon skbs in AP mode
      ath9k: Disable staggered Beacon frame scheduling
      mac80211: Disable requests for new scans in AP mode
      ath9k: Do not remove header padding on RX from short frames

Larry Finger (3):
      rtl8187: Improve wireless statistics for RTL8187
      rtl8187: Use usb anchor facilities to manage urbs
      b43legacy: Fix sparse warnings

Mohamed Abbas (1):
      iwlwifi: fix resume while txpower off

Pavel Roskin (1):
      airport: remove useless return in a function returning void

Rami Rosen (4):
      iwlwifi: cleanup (remove pm_state)
      iwlwifi: fix build error (iwl-rx.c).
      mac80211: misc cleanups
      iwlwifi: fix build warning (iwl-rx.c)

Reinette Chatre (1):
      mac80211: remove WARN_ON() from ieee80211_hw_config

Senthil Balasubramanian (7):
      wireless: Incorrect LEAP authentication algorithm identifier.
      ath9k: Adding AR9285 chipset register information.
      ath9k: Adding initvalues for Atheros AR9285 chipset.
      ath9k: Adding support for Atheros AR9285 chipset.
      ath9k: Incorrect band enum causes invalid antenna configuration.
      ath9k: avoid rx frames with corrupted descriptor.
      ath9k: BH shouldn't be enabled when hardirqs are disabled.

Sujith (6):
      ath9k: Fix bug in rate table management
      ath9k: Maintain rate table choice after association
      ath9k: Add a debugfs file to show interrupt statistics
      ath9k: Remove remaining occurrences of CONFIG_SLOW_ANT_DIV
      ath9k: Merge structures ath_atx, ath_node_aggr with ath_node
      ath9k: Refactor struct ath_softc

Tomas Winkler (4):
      iwlwifi: remove unused clip_groups priv member
      iwlwifi: remove includes of iwl-helpers.h where not needed
      iwlwifi: remove 4965 from common uCode API structures
      iwlwifi: add contact email to MODULE_AUTHOR

Winkler, Tomas (4):
      iwlwifi: change email contact information
      iwlifi: remove twice defined SINGLE_FRAME RX FH MASK
      iwlwifi: 3945 remove qos module parameter
      iwlwifi: remove qos module parameter

Zhu, Yi (5):
      iwlwifi: fix time interval misuse in iwl_poll_{direct_}bit
      iwlwifi: fix "MAC in deep sleep" error
      iwlwifi: iwl_poll_{direct_}bit cleanup
      iwlwifi: use rmb/wmb to protect indirect mmio operation
      iwlwifi: use iwl_poll_direct_bit in EEPROM reading

 drivers/net/wireless/ath5k/pcu.c                  |    4 +-
 drivers/net/wireless/ath9k/ath9k.h                |    1 +
 drivers/net/wireless/ath9k/beacon.c               |   97 +-
 drivers/net/wireless/ath9k/calib.c                |   98 ++
 drivers/net/wireless/ath9k/core.h                 |  356 +++--
 drivers/net/wireless/ath9k/debug.c                |  102 ++
 drivers/net/wireless/ath9k/eeprom.c               | 1826 +++++++++++++++++----
 drivers/net/wireless/ath9k/hw.c                   |  115 +-
 drivers/net/wireless/ath9k/hw.h                   |  140 ++-
 drivers/net/wireless/ath9k/initvals.h             | 1363 +++++++++++++++
 drivers/net/wireless/ath9k/mac.c                  |    5 +-
 drivers/net/wireless/ath9k/main.c                 |   80 +-
 drivers/net/wireless/ath9k/phy.h                  |    5 +
 drivers/net/wireless/ath9k/rc.c                   |   18 +-
 drivers/net/wireless/ath9k/recv.c                 |  121 +-
 drivers/net/wireless/ath9k/reg.h                  |  109 ++-
 drivers/net/wireless/ath9k/xmit.c                 |  141 +-
 drivers/net/wireless/b43legacy/debugfs.c          |    2 +-
 drivers/net/wireless/b43legacy/phy.c              |    6 +-
 drivers/net/wireless/ipw2x00/ipw2200.c            |   28 +-
 drivers/net/wireless/ipw2x00/ipw2200.h            |    1 +
 drivers/net/wireless/iwlwifi/iwl-3945-commands.h  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-core.h      |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-debug.h     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945-io.h        |   20 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c        |   14 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.h        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c           |   59 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h           |    8 +-
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h        |    8 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c           |   24 +-
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c           |   16 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd-check.c |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c         |    3 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h         |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c            |   34 +-
 drivers/net/wireless/iwlwifi/iwl-calib.c          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-calib.h          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h       |  111 +-
 drivers/net/wireless/iwlwifi/iwl-core.c           |   44 +-
 drivers/net/wireless/iwlwifi/iwl-core.h           |    4 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h            |   31 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c         |   30 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h         |    9 +-
 drivers/net/wireless/iwlwifi/iwl-fh.h             |    5 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-io.h             |   24 +-
 drivers/net/wireless/iwlwifi/iwl-led.c            |    3 +-
 drivers/net/wireless/iwlwifi/iwl-led.h            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-power.c          |    3 +-
 drivers/net/wireless/iwlwifi/iwl-power.h          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-rfkill.c         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-rfkill.h         |    2 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c             |  100 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-spectrum.c       |    4 +-
 drivers/net/wireless/iwlwifi/iwl-spectrum.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-sta.h            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c             |    4 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c       |   94 +-
 drivers/net/wireless/libertas/host.h              |    1 +
 drivers/net/wireless/libertas/main.c              |   60 +
 drivers/net/wireless/mac80211_hwsim.c             |    4 +
 drivers/net/wireless/orinoco/airport.c            |    2 +-
 drivers/net/wireless/orinoco/orinoco.c            |    6 +-
 drivers/net/wireless/orinoco/orinoco_cs.c         |    8 +-
 drivers/net/wireless/orinoco/spectrum_cs.c        |    8 +-
 drivers/net/wireless/p54/p54common.c              |   59 +-
 drivers/net/wireless/p54/p54pci.c                 |    7 -
 drivers/net/wireless/p54/p54usb.c                 |  151 ++-
 drivers/net/wireless/p54/p54usb.h                 |    1 +
 drivers/net/wireless/rtl818x/rtl8187.h            |    2 +-
 drivers/net/wireless/rtl818x/rtl8187_dev.c        |  124 +-
 include/linux/ieee80211.h                         |    2 +-
 include/linux/rfkill.h                            |    7 -
 include/net/ieee80211.h                           |    5 +-
 include/net/mac80211.h                            |   32 +-
 net/mac80211/Makefile                             |    2 +
 net/mac80211/cfg.c                                |    6 +-
 net/mac80211/ieee80211_i.h                        |    4 +-
 net/mac80211/main.c                               |   26 +-
 net/mac80211/mlme.c                               |   10 +-
 net/mac80211/rx.c                                 |   17 +-
 net/mac80211/tx.c                                 |    1 -
 net/mac80211/wext.c                               |   11 +-
 net/rfkill/rfkill.c                               |   83 +-
 net/wireless/Makefile                             |    2 +
 net/wireless/nl80211.c                            |   40 +-
 98 files changed, 4513 insertions(+), 1500 deletions(-)

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2008-12-12.patch.bz2

-- 
John W. Linville		Linux should be at the core
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			of your literate lifestyle.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
