From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6-2009-12-04
Date: Fri, 4 Dec 2009 14:58:23 -0500
Message-ID: <20091204195823.GB5786@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

I have one last large batch of wireless patches that I'd like to get
into the merge for 2.6.33.  I hope it isn't too late!  To be honest,
I had my head down yesterday mopping-up some things for my "real job"
and missed your other email -- please forgive me! :-)

Most of these have spent the last week or so in linux-next.
The rest are mostly small and isolated stuff that would come close to
qualifying during "bugfix only" rules anyway, so I hope you'll take
the whole batch.  If you can't swallow that, then I have prepared an
"already-in-next" branch as an alternative.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 4ba3eb034fb6fd1990ccc5a6d71d5abcda37b905:
  David S. Miller (1):
        Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Alban Browaeys (1):
      wireless : use a dedicated workqueue for cfg80211.

Alexey Dobriyan (2):
      ray_cs: convert to proc_fops
      ipw2x00: convert to seq_file

Benoit Papillault (1):
      ath9k: Proper padding/unpadding for the TX/RX path.

Eric Dumazet (1):
      mac80211: Speedup ieee80211_remove_interfaces()

Felix Fietkau (3):
      ath9k: properly use the mac80211 rate control api
      ath9k: clean up rc rate table
      ath9k: separate debugfs support from CONFIG_ATH_DEBUG

Gabor Juhos (1):
      ath9k: enable 2GHz band only if the device supports it

Gertjan van Wingerde (7):
      rt2x00: Only initialize HT on rt2800 devices that support it.
      rt2x00: Remove unused variable frame_control from rt2x00mac_tx.
      rt2x00: Clean up use of rt2x00_intf_is_pci.
      rt2x00: Fix typo (lengt --> length) in rt2x00queue.c
      rt2x00: Whitespace cleanup.
      rt2x00: Centralize setting of extra TX headroom requested by rt2x00.
      rt2x00: Fix padding bug on L2PAD devices.

Holger Schurig (5):
      libertas: rename persistcfg.c -> mesh.c
      libertas: introduce mesh.h
      libertas: moveing mesh-related functions into mesh.c
      libertas: move mesh-only ethtool operations into mesh.c
      libertas: move mesh command handling into mesh.c

Jean Tourrilhes (1):
      WE: Fix set events not propagated

Johannes Berg (5):
      mac80211: move cmntr flag out of rx flags
      mac80211: move aMPDU RX reorder code
      mac80211: correctly place aMPDU RX reorder code
      mac80211: log more data when tracing
      b43: fix two warnings

John W. Linville (1):
      ath9k: remove warnings related to signed/unsigned type mismatch

Jouni Malinen (1):
      mac80211: Fix TX status reporting for injected data frames

Juuso Oikarinen (3):
      wl1271: Decrease BET consecutive terminated beacons value to 10
      wl1271: Prevent PSM-entry retry loop if PSM cancelled
      wl1271: Set PSM support flags in driver configuration

Kalle Valo (1):
      cfg80211: indent regulatory messages with spaces

Larry Finger (2):
      b43: avoid PPC fault during resume
      b43legacy: avoid PPC fault during resume

Luciano Coelho (5):
      wl1271: fix the inetdev notifier callback return values
      wl1271: set radio and general params also for PLT
      wl1271: fix radio and general parameters commands
      wl1271: remove workaround to ignore -EIO from radio and general params
      wl1271: Remove REF_CLK hack

Luis R. Rodriguez (2):
      ath9k: fix processing of TX PS null data frames
      ath9k: Fix maximum tx fifo settings for single stream devices

Michael Buesch (1):
      airo: Fix integer overflow warning

Reinette Chatre (1):
      iwlwifi: driver version track kernel version

Samuel Ortiz (14):
      MAINTAINERS: Add iwmc3200wifi entry
      iwmc3200wifi: Parse HT channels EEPROM entries
      iwmc3200wifi: Dont set the UMAC power limit when interface is down
      iwmc3200wifi: Update wireless_mode with eeprom values
      iwmc3200wifi: 802.11n Tx aggregation support
      iwmc3200wifi: Add stopped queue to debugfs
      iwmc3200wifi: Remove tx concatenation option
      nl80211: PMKSA caching support
      cfg80211: Add PMKSA wext compatibility handler
      iwmc3200wifi: Implement cfg80211 PMKSA API
      iwmc3200wifi: Update wiwi priority table
      iwmc3200wifi: Coex table command does not expect a response
      iwmc3200wifi: Add wifi-wimax coexistence mode as a module parameter
      iwmc3200wifi: Enable wimax core through module parameter

Vivek Natarajan (1):
      ath9k: Ensure a fair beacon distribution in IBSS mode.

Wey-Yi Guy (2):
      iwl3945: remove duplicated event logging code
      iwlwifi: indicate uCode type when fail dump error/event log

Zhu Yi (3):
      iwmc3200wifi: Set wireless mode correctly
      iwmc3200wifi: fix NULL pointer dereference in pmkid update
      ipw2100: fix rebooting hang with driver loaded

 MAINTAINERS                                  |    9 +
 drivers/net/wireless/airo.c                  |    2 +-
 drivers/net/wireless/ath/ath9k/Kconfig       |   13 +-
 drivers/net/wireless/ath/ath9k/Makefile      |    2 +-
 drivers/net/wireless/ath/ath9k/ath9k.h       |   10 +-
 drivers/net/wireless/ath/ath9k/beacon.c      |   24 +-
 drivers/net/wireless/ath/ath9k/common.c      |   26 +-
 drivers/net/wireless/ath/ath9k/common.h      |    3 +
 drivers/net/wireless/ath/ath9k/debug.c       |   20 +-
 drivers/net/wireless/ath/ath9k/debug.h       |   11 +-
 drivers/net/wireless/ath/ath9k/hw.c          |   38 +-
 drivers/net/wireless/ath/ath9k/hw.h          |    7 +-
 drivers/net/wireless/ath/ath9k/mac.c         |   38 +-
 drivers/net/wireless/ath/ath9k/mac.h         |   15 +-
 drivers/net/wireless/ath/ath9k/main.c        |  172 ++--
 drivers/net/wireless/ath/ath9k/rc.c          |  433 ++++------
 drivers/net/wireless/ath/ath9k/rc.h          |    5 +-
 drivers/net/wireless/ath/ath9k/reg.h         |   15 +-
 drivers/net/wireless/ath/ath9k/xmit.c        |  140 +++-
 drivers/net/wireless/b43/leds.c              |    1 +
 drivers/net/wireless/b43/rfkill.c            |   10 +-
 drivers/net/wireless/b43legacy/rfkill.c      |    7 +
 drivers/net/wireless/ipw2x00/ipw2100.c       |   11 +
 drivers/net/wireless/ipw2x00/libipw_module.c |   33 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c       |    8 +-
 drivers/net/wireless/iwlwifi/iwl-core.h      |    4 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c  |   13 +-
 drivers/net/wireless/iwmc3200wifi/cfg80211.c |   35 +
 drivers/net/wireless/iwmc3200wifi/commands.c |   77 ++-
 drivers/net/wireless/iwmc3200wifi/commands.h |   23 +
 drivers/net/wireless/iwmc3200wifi/debugfs.c  |   23 +
 drivers/net/wireless/iwmc3200wifi/eeprom.c   |   50 ++
 drivers/net/wireless/iwmc3200wifi/eeprom.h   |   29 +-
 drivers/net/wireless/iwmc3200wifi/iwm.h      |   11 +-
 drivers/net/wireless/iwmc3200wifi/main.c     |   44 +-
 drivers/net/wireless/iwmc3200wifi/netdev.c   |    8 +
 drivers/net/wireless/iwmc3200wifi/rx.c       |   66 ++
 drivers/net/wireless/iwmc3200wifi/tx.c       |   66 ++-
 drivers/net/wireless/iwmc3200wifi/umac.h     |   36 +-
 drivers/net/wireless/libertas/Makefile       |    2 +-
 drivers/net/wireless/libertas/cmd.c          |  168 ----
 drivers/net/wireless/libertas/decl.h         |    8 +-
 drivers/net/wireless/libertas/dev.h          |   12 +-
 drivers/net/wireless/libertas/ethtool.c      |   84 +--
 drivers/net/wireless/libertas/main.c         |  357 +--------
 drivers/net/wireless/libertas/mesh.c         | 1141 ++++++++++++++++++++++++++
 drivers/net/wireless/libertas/mesh.h         |   78 ++
 drivers/net/wireless/libertas/persistcfg.c   |  453 ----------
 drivers/net/wireless/libertas/rx.c           |   11 +-
 drivers/net/wireless/libertas/tx.c           |    7 +-
 drivers/net/wireless/libertas/wext.h         |    5 +-
 drivers/net/wireless/ray_cs.c                |   36 +-
 drivers/net/wireless/rt2x00/rt2400pci.c      |   28 +-
 drivers/net/wireless/rt2x00/rt2500pci.c      |   29 +-
 drivers/net/wireless/rt2x00/rt2500usb.c      |   29 +-
 drivers/net/wireless/rt2x00/rt2800lib.c      |   29 +-
 drivers/net/wireless/rt2x00/rt2800pci.c      |   31 +-
 drivers/net/wireless/rt2x00/rt2800usb.c      |   25 +-
 drivers/net/wireless/rt2x00/rt2x00.h         |    1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c      |    5 +
 drivers/net/wireless/rt2x00/rt2x00mac.c      |    3 -
 drivers/net/wireless/rt2x00/rt2x00queue.c    |    6 +-
 drivers/net/wireless/rt2x00/rt61pci.c        |   26 +-
 drivers/net/wireless/rt2x00/rt73usb.c        |   26 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.c     |  107 +++
 drivers/net/wireless/wl12xx/wl1271_cmd.h     |   72 ++
 drivers/net/wireless/wl12xx/wl1271_event.c   |    8 +-
 drivers/net/wireless/wl12xx/wl1271_init.c    |  117 +---
 drivers/net/wireless/wl12xx/wl1271_init.h    |   70 --
 drivers/net/wireless/wl12xx/wl1271_main.c    |   32 +-
 include/linux/ieee80211.h                    |    2 +
 include/linux/nl80211.h                      |   11 +
 include/net/cfg80211.h                       |   28 +
 include/net/mac80211.h                       |    4 +
 net/mac80211/driver-trace.h                  |   26 +-
 net/mac80211/ieee80211_i.h                   |    4 +-
 net/mac80211/iface.c                         |   14 +-
 net/mac80211/rx.c                            |  589 +++++++-------
 net/mac80211/status.c                        |    6 +-
 net/wireless/core.c                          |   12 +-
 net/wireless/core.h                          |    2 +
 net/wireless/ibss.c                          |    2 +-
 net/wireless/nl80211.c                       |  120 +++
 net/wireless/reg.c                           |    6 +-
 net/wireless/scan.c                          |    2 +-
 net/wireless/sme.c                           |    6 +-
 net/wireless/wext-compat.c                   |   42 +
 net/wireless/wext-core.c                     |    3 +-
 88 files changed, 3161 insertions(+), 2262 deletions(-)
 create mode 100644 drivers/net/wireless/libertas/mesh.c
 create mode 100644 drivers/net/wireless/libertas/mesh.h
 delete mode 100644 drivers/net/wireless/libertas/persistcfg.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2009-12-04.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
