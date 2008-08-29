From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2008-08-29
Date: Fri, 29 Aug 2008 16:54:14 -0400
Message-ID: <20080829205414.GB11718@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is this week's supply of stuff for -next -- mostly cleanups and
other driver updates.  Please let me know if there are problems!

Thanks,

John

P.S.  For anyone else, I'm mostly through my patch backlog.
If you sent a patch more than a week ago, it hasn't been merged,
and you don't know why, then you should probably resend it to
linux-wireless...thanks!

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 4d40555250320520c5398569457962b3984fc75e:
  David S. Miller (1):
        Merge branch 'lvs-next-2.6' of git://git.kernel.org/.../horms/lvs-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Chr (2):
      p54: take tx_queue's lock in rx_frame_sent
      p54: redo queue numbering

Christian Lamparter (2):
      p54: fix rssi auto calibration
      p54pci: rx tasklet refactoring

Dan Williams (4):
      libertas: convert CMD_802_11_RF_TX_POWER to a direct command
      libertas: convert CMD_802_11_DEAUTHENTICATE to a direct command
      libertas: convert CMD_802_11_RADIO_CONTROL to a direct command
      libertas: convert adhoc operations to direct commands

Daniel Wagner (1):
      mac80211: Use only precedence level of DSCP field for frame classification

Felipe Balbi (1):
      rfkill: add missing line break

Harvey Harrison (1):
      libertas: use the common frame control functions

Henrique de Moraes Holschuh (3):
      rfkill: use strict_strtoul (v2)
      rfkill: add WARN and BUG_ON paranoia (v2)
      rfkill: rename rfkill_mutex to rfkill_global_mutex

Huang Weiyi (1):
      wireless: remove unused #include <version.h>

Ivo van Doorn (5):
      rt2x00: Fix race conditions in flag handling
      rt2x00: Map extra_tx_headroom to DMA
      rt2x00: Initialize txop during conf_tx() callback
      rt2x00: Add Signal type flag
      rt2x00: Release rt2x00 2.2.1

Johannes Berg (1):
      mac80211: fill start-sequence-number for BA session start

Jouni Malinen (10):
      mac80211/cfg80211: Add BSS configuration options for AP mode
      ath9k: Allow AP mode to be enabled
      ath9k: Updated Beacon generation to use mac80211-style
      ath9k: Fix TX status reporting
      ath9k: Assign seq# when mac80211 requests this
      ath9k: Fix TX control flag use for no ACK and RTS/CTS
      mac80211: Handle scan result IEs in one block
      mac80211_hwsim: Add minimal IEEE 802.11n support
      ath9k: Use mac80211 for multicast power save buffering
      mac80211/cfg80211: HT capabilities for NEW_STA

Larry Finger (2):
      ssb: Update for Rev. 5 SPROM
      ssb: Clean up extraction of MAC addresses from SPROM

Mattias Nissler (2):
      rt2x00: Only configure hardware when radio is enabled
      rt2x00: skb->data pointer should not include TX descriptor

Michael Buesch (2):
      b43: Implement dynamic PHY API
      b43: Rewrite TX power adjustment

Sujith (20):
      ath9k: Merge reset functions
      ath9k: RX Filter cleanup
      ath9k: Use bitfields for buffer type
      ath9k: Remove a few unnecessary macros
      ath9k: Remove ar5416hal and assign default values directly
      ath9k: Unused macros, variables
      ath9k: Use a single opmode variable
      ath9k: Use bitfields for sc operations
      ath9k: Use ah_curchan and remove sc_curchan which is redundant
      ath9k: Trim struct ath_softc
      ath9k: Remove remaining occurences of ath_skb_map functions
      ath9k: Random cleanup
      ath9k: Miscellaneous fixes
      mac80211: Add an 802.11n definition
      ath9k: Use definition from ieee80211.h
      ath9k: Add IEEE80211_HW_RX_INCLUDES_FCS to hw flags
      ath9k: Remove more dead code
      ath9k: Do not update frame's duration field
      ath9k: Remove sc_lastrx as we don't use it anywhere
      ath9k: rc.h cleanup

Vasanthakumar Thiagarajan (1):
      ath9k: Add LED support

 drivers/net/wireless/ath9k/ath9k.h          |   55 +-
 drivers/net/wireless/ath9k/beacon.c         |  259 +--
 drivers/net/wireless/ath9k/core.c           |  306 +--
 drivers/net/wireless/ath9k/core.h           |  248 +--
 drivers/net/wireless/ath9k/hw.c             |  150 +-
 drivers/net/wireless/ath9k/hw.h             |  120 +-
 drivers/net/wireless/ath9k/main.c           |  256 ++-
 drivers/net/wireless/ath9k/phy.h            |   12 +-
 drivers/net/wireless/ath9k/rc.c             |  183 +-
 drivers/net/wireless/ath9k/rc.h             |  222 +-
 drivers/net/wireless/ath9k/recv.c           |   81 +-
 drivers/net/wireless/ath9k/reg.h            |    6 -
 drivers/net/wireless/ath9k/xmit.c           |  404 ++--
 drivers/net/wireless/b43/Makefile           |    4 +-
 drivers/net/wireless/b43/b43.h              |  137 +-
 drivers/net/wireless/b43/debugfs.c          |   79 +-
 drivers/net/wireless/b43/lo.c               |  120 +-
 drivers/net/wireless/b43/lo.h               |    4 +-
 drivers/net/wireless/b43/main.c             |  184 +-
 drivers/net/wireless/b43/nphy.c             |  148 ++-
 drivers/net/wireless/b43/nphy.h             |   54 +-
 drivers/net/wireless/b43/phy.c              | 3421 +--------------------------
 drivers/net/wireless/b43/phy.h              |  340 ---
 drivers/net/wireless/b43/phy_a.c            |  543 +++++
 drivers/net/wireless/b43/phy_a.h            |  124 +
 drivers/net/wireless/b43/phy_common.c       |  367 +++
 drivers/net/wireless/b43/phy_common.h       |  381 +++
 drivers/net/wireless/b43/phy_g.c            | 3251 +++++++++++++++++++++++++
 drivers/net/wireless/b43/phy_g.h            |  209 ++
 drivers/net/wireless/b43/rfkill.c           |    5 +-
 drivers/net/wireless/b43/sysfs.c            |   23 +-
 drivers/net/wireless/b43/tables.c           |   43 +-
 drivers/net/wireless/b43/tables_nphy.c      |    2 +-
 drivers/net/wireless/b43/wa.c               |    2 +-
 drivers/net/wireless/b43/xmit.c             |    8 +-
 drivers/net/wireless/b43legacy/main.c       |    1 -
 drivers/net/wireless/iwlwifi/iwl-3945-led.c |    1 -
 drivers/net/wireless/iwlwifi/iwl-led.c      |    1 -
 drivers/net/wireless/iwlwifi/iwl-rfkill.c   |    1 -
 drivers/net/wireless/libertas/assoc.c       |  744 +++----
 drivers/net/wireless/libertas/assoc.h       |   18 +-
 drivers/net/wireless/libertas/cmd.c         |  147 +-
 drivers/net/wireless/libertas/cmd.h         |    6 +
 drivers/net/wireless/libertas/cmdresp.c     |   33 -
 drivers/net/wireless/libertas/decl.h        |    1 -
 drivers/net/wireless/libertas/dev.h         |    7 +-
 drivers/net/wireless/libertas/host.h        |   26 +-
 drivers/net/wireless/libertas/hostcmd.h     |   50 +-
 drivers/net/wireless/libertas/main.c        |   21 +-
 drivers/net/wireless/libertas/scan.c        |    5 +
 drivers/net/wireless/libertas/wext.c        |  148 +-
 drivers/net/wireless/libertas_tf/main.c     |   20 +-
 drivers/net/wireless/mac80211_hwsim.c       |   16 +-
 drivers/net/wireless/p54/p54.h              |    2 +-
 drivers/net/wireless/p54/p54common.c        |  170 +-
 drivers/net/wireless/p54/p54common.h        |   23 +-
 drivers/net/wireless/p54/p54pci.c           |  242 ++-
 drivers/net/wireless/p54/p54pci.h           |   10 +-
 drivers/net/wireless/rt2x00/rt2400pci.c     |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c     |    4 +-
 drivers/net/wireless/rt2x00/rt2500usb.c     |    7 +-
 drivers/net/wireless/rt2x00/rt2x00.h        |   17 +-
 drivers/net/wireless/rt2x00/rt2x00config.c  |    4 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c     |   68 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c     |   75 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c   |   31 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h   |    9 +-
 drivers/net/wireless/rt2x00/rt2x00rfkill.c  |    6 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c     |   21 +-
 drivers/net/wireless/rt2x00/rt61pci.c       |   73 +-
 drivers/net/wireless/rt2x00/rt73usb.c       |   74 +-
 drivers/ssb/pci.c                           |   84 +-
 include/linux/ieee80211.h                   |    1 +
 include/linux/nl80211.h                     |   31 +
 include/linux/ssb/ssb_regs.h                |   19 +-
 include/net/cfg80211.h                      |   23 +
 include/net/mac80211.h                      |    9 +
 net/mac80211/cfg.c                          |   42 +
 net/mac80211/ieee80211_i.h                  |   18 +-
 net/mac80211/main.c                         |    5 +-
 net/mac80211/mlme.c                         |  230 +--
 net/mac80211/wme.c                          |    2 -
 net/rfkill/rfkill.c                         |  104 +-
 net/wireless/nl80211.c                      |   62 +
 84 files changed, 7730 insertions(+), 6735 deletions(-)
 delete mode 100644 drivers/net/wireless/b43/phy.h
 create mode 100644 drivers/net/wireless/b43/phy_a.c
 create mode 100644 drivers/net/wireless/b43/phy_a.h
 create mode 100644 drivers/net/wireless/b43/phy_common.c
 create mode 100644 drivers/net/wireless/b43/phy_common.h
 create mode 100644 drivers/net/wireless/b43/phy_g.c
 create mode 100644 drivers/net/wireless/b43/phy_g.h

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2008-08-29.patch.bz2

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
