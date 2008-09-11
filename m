From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2008-09-11
Date: Thu, 11 Sep 2008 16:32:05 -0400
Message-ID: <20080911203205.GK3423@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

The latest round of patches intended for 2.6.28.  Johannes has returned,
so there is of course a ton of mac80211 stuff (mostly cleanups, etc).  :-)

Please let me know if there are problems!

Thanks,

John
---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 1e493d1946a0b26b79001c18d7312d536156ff5a:
  David S. Miller (1):
        ipv6: On interface down/unregister, purge icmp routes too.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Abhijeet Kolekar (1):
      iwl3945 : Code cleanup

Anna Neal (1):
      libertas: Improvements on automatic tx power control via SIOCSIWTXPOW.

Christian Lamparter (5):
      p54: 32-bit tsf timestamps
      p54: add more rx filters
      p54: add lots of useful rx/tx statistics
      p54: control output power levels
      p54: 802.11a 5GHz phy support

Dan Williams (1):
      libertas: clear current command on card removal

Ehud Gavron (1):
      b43legacy: Fix to enhance TX speed

Emmanuel Grumbach (1):
      iwlwifi: remove uneeded declarations

Grumbach, Emmanuel (1):
      iwlwifi: use the results from disconnected antenna algorithm

Guy Cohen (2):
      iwlwifi: fix searching for best rate in new search column
      iwlwifi: Added support for 3 antennas

Ivo van Doorn (3):
      rt2x00: Revert "rt2x00: Fix the beacon length bug"
      rt2x00: Make RFKILL enabled by default
      rt2x00: Make rt2x00 LEDS invisible config option

Johannes Berg (25):
      mac80211: move some RCU locking into an if branch
      mac80211: make conf_tx non-atomic
      mac80211: BSS info: check channel first
      mac80211: fix action frame length checks
      mac80211: fix typo in action frame handling
      mac80211: move IE parsing to util file
      mac80211: reorder mlme code
      mac80211: use sdata pointer for scan interface
      mac80211: remove useless non-NULL tests from scan results code
      mac80211: start moving scan code from mlme
      mac80211: refactor and move scan RX code
      mac80211: move BSS handling to scan code
      mac80211: move some HT code out of mlme.c
      mac80211: move some HT code out of main.c
      mac80211: clarify scan request
      mac80211: simplify scan start
      mac80211: remove useless 'ibss' parameter
      mac80211: reorder frame code in mlme
      mac80211: consolidate deauth/disassoc
      mac80211: split ieee80211_sta_def_wmm_params
      mac80211: initialise queue QoS parameters at hw start
      mac80211: make BA session handling independent of STA mode
      mac80211: move spectrum management code out
      mac80211: make ieee80211_rx_h_mgmt more readable
      mac80211: move frame TX function

Jouni Malinen (1):
      mac80211: Reorder debugfs calls during netdev deinit

Larry Finger (1):
      b43legacy: Fix failure in rate-adjustment mechanism

Michael Buesch (3):
      b43: Fix QoS defaults
      b43 G-PHY: Remove mmiowb()
      b43: Remove QoS update workqueue

Ron Rindjunsky (1):
      iwlwifi: rename ps_mode to sm_ps

Tomas Winkler (5):
      mac80211: change MIMO_PS to SM_PS
      mac80211: restructure disassoc/deauth flows
      mac80211: disassociate when moving to new BSS
      mac80211: remove disassociation code from ieee80211_set_associated
      mac80211: stop queues before carrier off

Zhu Yi (1):
      iwlwifi: fix compile warning

 drivers/net/wireless/ath9k/main.c          |    2 +-
 drivers/net/wireless/b43/b43.h             |    7 +-
 drivers/net/wireless/b43/main.c            |  119 +-
 drivers/net/wireless/b43/phy_g.c           |    1 -
 drivers/net/wireless/b43legacy/phy.c       |   32 +-
 drivers/net/wireless/b43legacy/xmit.c      |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c    |   14 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c    |    5 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c  |  163 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h  |   29 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c     |   12 +-
 drivers/net/wireless/iwlwifi/iwl-calib.c   |   15 +-
 drivers/net/wireless/iwlwifi/iwl-core.c    |   66 +-
 drivers/net/wireless/iwlwifi/iwl-core.h    |   10 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h     |   62 +-
 drivers/net/wireless/iwlwifi/iwl-power.c   |   34 +-
 drivers/net/wireless/iwlwifi/iwl-power.h   |    4 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c    |    3 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c     |    8 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c      |    9 +-
 drivers/net/wireless/libertas/cmd.c        |   64 +
 drivers/net/wireless/libertas/cmd.h        |    6 +
 drivers/net/wireless/libertas/defs.h       |    9 +
 drivers/net/wireless/libertas/host.h       |    1 +
 drivers/net/wireless/libertas/hostcmd.h    |   24 +-
 drivers/net/wireless/libertas/main.c       |   20 +-
 drivers/net/wireless/libertas/wext.c       |   31 +-
 drivers/net/wireless/p54/p54.h             |    9 +
 drivers/net/wireless/p54/p54common.c       |  256 ++-
 drivers/net/wireless/p54/p54common.h       |   23 +-
 drivers/net/wireless/rt2x00/Kconfig        |   75 +-
 drivers/net/wireless/rt2x00/rt2400pci.c    |   16 +-
 drivers/net/wireless/rt2x00/rt2500pci.c    |   16 +-
 drivers/net/wireless/rt2x00/rt2500usb.c    |   20 +-
 drivers/net/wireless/rt2x00/rt2x00rfkill.c |   50 +-
 drivers/net/wireless/rt2x00/rt61pci.c      |   20 +-
 drivers/net/wireless/rt2x00/rt73usb.c      |   20 +-
 include/linux/ieee80211.h                  |   30 +-
 include/net/mac80211.h                     |    2 +-
 net/mac80211/Makefile                      |    3 +
 net/mac80211/ht.c                          |  992 +++++++++
 net/mac80211/ieee80211_i.h                 |   79 +-
 net/mac80211/iface.c                       |    4 +-
 net/mac80211/main.c                        |  388 +----
 net/mac80211/mesh_hwmp.c                   |    8 +-
 net/mac80211/mesh_plink.c                  |    6 +-
 net/mac80211/mlme.c                        | 3121 ++++++----------------------
 net/mac80211/rx.c                          |   90 +-
 net/mac80211/scan.c                        |  933 +++++++++
 net/mac80211/spectmgmt.c                   |   86 +
 net/mac80211/util.c                        |  184 ++
 51 files changed, 3855 insertions(+), 3328 deletions(-)
 create mode 100644 net/mac80211/ht.c
 create mode 100644 net/mac80211/scan.c
 create mode 100644 net/mac80211/spectmgmt.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2008-09-11.patch.bz2

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
