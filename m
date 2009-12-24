From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2009-12-24
Date: Thu, 24 Dec 2009 15:47:22 -0500
Message-ID: <20091224204722.GA678@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is the usual first batch of pent-up wireless patches after the
merge window.  It is the usual collection of various driver updates
along with a dozen or so mac80211/infrastructure changes.  There is
still more, but lots/most of what remains is dependent not only on this
batch but also on the fixes that only recently made it into net-next-2.6
(and which are not yet in wireless-next-2.6).  So, something to look
forward to... :-)

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit a252e749f1ae17e43ccc5824f7b1b5854417c98b:
  Linus Torvalds (1):
        sctp: fix compile error due to sysctl mismerge

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Alban Browaeys (4):
      rt2x00 : bail out of regbusy_read if device is removed.
      rt2x00 : modify padding location.
      rt2x00 : avoid timestamp for monitor injected frame.
      rt2x00 : trim the skb after having the l2pad removed.

Benoit PAPILLAULT (1):
      rt2x00: Disable RX aggregation for rt2800usb

Benoit Papillault (1):
      rt2x00: Fix rt2800usb RX frame format and as such L2PAD

Christian Lamparter (5):
      ar9170: remove dead definitions
      ar9170: improve network latency
      ar9170: remove redundant frame flags
      ar9170: small misc changes
      ar9170: fix AC_VIDEO txop parameter

Colin Ian King (1):
      wireless: hostap, fix oops due to early probing interrupt

Emese Revfy (1):
      iwlwifi: Constify struct iwl_ops

Gertjan van Wingerde (5):
      rt2x00: Further L2 padding fixes.
      rt2x00: Remove SKBDESC_L2_PADDED flag.
      rt2x00: Reorganize L2 padding inserting function.
      rt2x00: Only remove L2 padding in received frames if there is payload.
      rt2x00: Fix trimming of L2 padded frames.

Holger Schurig (9):
      libertas: use priv->mesh_tlv instead of priv->mesh_fw_ver
      libertas: remove mesh_autostart_enabled and sync_channel
      libertas: move mesh-related definitions into mesh.h
      libertas: decouple mesh and rtap
      libertas: move mesh SSID initialization into mesh.c
      libertas: add access functions for mesh open/connect status
      libertas: make mesh configurable
      libertas: remove priv->capability
      libertas: remove priv->ratebitmap

Joe Perches (1):
      iwmc3200wifi: Avoid an offset calculation for each management frame.

Johannes Berg (10):
      mac80211: make station management completely depend on vif
      mac80211: reduce reliance on netdev
      mac80211: trace interface name
      mac80211: enable spatial multiplexing powersave
      mac80211_hwsim: implement ampdu action
      mac80211: allow disabling 40MHz on 2.4GHz
      cfg80211: avoid sending spurious deauth to userspace
      mac80211: dont try to use existing sta for AP
      mac80211: disallow fixing bitrates with hw rate control
      iwlwifi: use new mac80211 SMPS

John W. Linville (2):
      wireless: report reasonable bitrate for MCS rates through wext
      wireless: support internal statically compiled regulatory database

Jouni Malinen (1):
      mac80211_hwsim: Check all local addresses for TX Ack status

Jussi Kivilinna (2):
      rndis_wlan: move copy of module parameters to separate function
      rndis_wlan: copy module parameters for bcm4320a devices too

Kalle Valo (12):
      wl1251: add tx queue status to debugfs
      wl1251: print a debug message when tx_queue is full
      wl1251: fix error handling in wl1251_op_config()
      wl1251: reduce ELP wakeup timeout
      wl1251: simplify ELP wakeup time calculation
      wl1251: use __dev_alloc_skb() on RX
      wl1251: implement acx_ac_cfg to configure hardware queues
      wl1251: implement wl1251_acx_tid_cfg()
      wl1251: implement WMM
      wl1251: update tx_hdr when aliging skb in tx
      wl1251: enable WMM
      mac80211: remove payload alignment warning

Kenichi HORIO (1):
      rt73usb: add WLI-U2-H54HP

Larry Finger (1):
      rtl8180: Remove usage of deprecated 'qual'

Luis R. Rodriguez (5):
      ath9k_hw: remove unused ath9k_hw_devname() and ath9k_hw_probe()
      ath9k: add MCS rate index back to debufs rcstat
      mac80211: make debugfs mcs set entry reflect 16 bits
      mac80211: parse the HT capabilities info through debugfs
      mac80211: only bother printing highest data rate on debugfs if its set

Stefan Seyfried (2):
      ar9170usb: add Sphairon Homelink 1202 USB ID
      zd1211rw: improve ejecting of fake CDROM

Sujith (3):
      ath9k: Clarify Interrupt mitigation
      ath9k: Remove ANI lock
      ath9k: Fix TX poll routine

Wey-Yi Guy (5):
      iwlwifi: log CT_CARD_DISABLED flag
      iwlwifi: dump "Control and Status Register" when detect uCode HW/SW error
      iwlwifi: add continuous uCode event log capability
      iwlwifi: on-screen event log dump
      iwlwifi: remove extra error msg on sensitivity calibration

Zhu Yi (2):
      wireless: add ieee80211_amsdu_to_8023s
      iwmc3200wifi: rx aggregation support

gregor kowski (1):
      mac80211 : fix a race with update_tkip_key

 Documentation/networking/regulatory.txt      |   24 ++
 drivers/net/wireless/ath/ar9170/ar9170.h     |    9 +-
 drivers/net/wireless/ath/ar9170/hw.h         |    1 +
 drivers/net/wireless/ath/ar9170/mac.c        |    2 +-
 drivers/net/wireless/ath/ar9170/main.c       |  102 ++++-----
 drivers/net/wireless/ath/ar9170/usb.c        |    2 +
 drivers/net/wireless/ath/ath9k/ath9k.h       |    1 -
 drivers/net/wireless/ath/ath9k/debug.c       |   38 +++-
 drivers/net/wireless/ath/ath9k/hw.c          |   40 +---
 drivers/net/wireless/ath/ath9k/hw.h          |    2 +-
 drivers/net/wireless/ath/ath9k/main.c        |   21 +--
 drivers/net/wireless/ath/ath9k/rc.h          |    4 +
 drivers/net/wireless/hostap/hostap_hw.c      |    9 +
 drivers/net/wireless/iwlwifi/iwl-1000.c      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c      |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h      |    3 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c      |    3 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c      |   10 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c      |    8 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c       |  251 +++++++++++++++++++----
 drivers/net/wireless/iwlwifi/iwl-calib.c     |    7 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-core.c      |  128 +++++++++---
 drivers/net/wireless/iwlwifi/iwl-core.h      |   10 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h     |    2 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c   |  105 +++++++++-
 drivers/net/wireless/iwlwifi/iwl-dev.h       |   30 +++
 drivers/net/wireless/iwlwifi/iwl-devtrace.c  |    2 +
 drivers/net/wireless/iwlwifi/iwl-devtrace.h  |   44 ++++
 drivers/net/wireless/iwlwifi/iwl3945-base.c  |  101 ++++++---
 drivers/net/wireless/iwmc3200wifi/rx.c       |   71 +++++--
 drivers/net/wireless/libertas/Kconfig        |    6 +
 drivers/net/wireless/libertas/Makefile       |    2 +-
 drivers/net/wireless/libertas/assoc.c        |   17 +--
 drivers/net/wireless/libertas/cmd.c          |   22 +--
 drivers/net/wireless/libertas/cmd.h          |   12 -
 drivers/net/wireless/libertas/cmdresp.c      |   16 +--
 drivers/net/wireless/libertas/defs.h         |    7 -
 drivers/net/wireless/libertas/dev.h          |    7 +-
 drivers/net/wireless/libertas/ethtool.c      |    2 +
 drivers/net/wireless/libertas/main.c         |   42 ++--
 drivers/net/wireless/libertas/mesh.c         |   29 ++-
 drivers/net/wireless/libertas/mesh.h         |   32 +++
 drivers/net/wireless/libertas/scan.c         |    2 +-
 drivers/net/wireless/libertas/tx.c           |    2 +-
 drivers/net/wireless/libertas/wext.c         |   26 ++-
 drivers/net/wireless/mac80211_hwsim.c        |   85 +++++++-
 drivers/net/wireless/rndis_wlan.c            |   42 +++--
 drivers/net/wireless/rt2x00/rt2800pci.c      |    6 +-
 drivers/net/wireless/rt2x00/rt2800usb.c      |   45 +++--
 drivers/net/wireless/rt2x00/rt2800usb.h      |   90 ++++++--
 drivers/net/wireless/rt2x00/rt2x00.h         |    6 +
 drivers/net/wireless/rt2x00/rt2x00dev.c      |   10 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c      |    3 +
 drivers/net/wireless/rt2x00/rt2x00queue.c    |   79 ++++----
 drivers/net/wireless/rt2x00/rt2x00queue.h    |    5 +-
 drivers/net/wireless/rt2x00/rt73usb.c        |    1 +
 drivers/net/wireless/rtl818x/rtl8180_dev.c   |    1 -
 drivers/net/wireless/wl12xx/wl1251.h         |    1 +
 drivers/net/wireless/wl12xx/wl1251_acx.c     |   69 ++++++
 drivers/net/wireless/wl12xx/wl1251_acx.h     |   87 ++++++++
 drivers/net/wireless/wl12xx/wl1251_debugfs.c |   23 ++
 drivers/net/wireless/wl12xx/wl1251_init.c    |    5 +
 drivers/net/wireless/wl12xx/wl1251_init.h    |   47 ++++
 drivers/net/wireless/wl12xx/wl1251_main.c    |   50 ++++-
 drivers/net/wireless/wl12xx/wl1251_ps.c      |    9 +-
 drivers/net/wireless/wl12xx/wl1251_rx.c      |    2 +-
 drivers/net/wireless/wl12xx/wl1251_tx.c      |    9 +-
 drivers/net/wireless/wl12xx/wl1251_tx.h      |   17 ++
 drivers/net/wireless/zd1211rw/zd_usb.c       |   14 +-
 include/linux/ieee80211.h                    |   30 +++-
 include/net/cfg80211.h                       |   22 ++-
 include/net/mac80211.h                       |   61 ++++++
 net/mac80211/Kconfig                         |   12 -
 net/mac80211/agg-rx.c                        |   15 +-
 net/mac80211/agg-tx.c                        |   25 +--
 net/mac80211/cfg.c                           |  112 +++++++---
 net/mac80211/debugfs_key.c                   |    2 +-
 net/mac80211/debugfs_netdev.c                |  166 ++++++++++-----
 net/mac80211/debugfs_netdev.h                |    9 +-
 net/mac80211/debugfs_sta.c                   |   64 +++++-
 net/mac80211/driver-ops.h                    |   29 ++--
 net/mac80211/driver-trace.h                  |   42 ++--
 net/mac80211/ht.c                            |   53 +++++-
 net/mac80211/ibss.c                          |   34 ++--
 net/mac80211/ieee80211_i.h                   |   21 ++-
 net/mac80211/iface.c                         |   62 +++++-
 net/mac80211/key.c                           |    6 +-
 net/mac80211/key.h                           |    8 +-
 net/mac80211/main.c                          |   50 ++++-
 net/mac80211/mesh.c                          |    4 +-
 net/mac80211/mesh_hwmp.c                     |   20 +-
 net/mac80211/mesh_pathtbl.c                  |    6 +-
 net/mac80211/mesh_plink.c                    |    6 +-
 net/mac80211/mlme.c                          |  192 +++++++++++------
 net/mac80211/pm.c                            |    4 +-
 net/mac80211/rx.c                            |  295 ++++++++++----------------
 net/mac80211/scan.c                          |    2 +-
 net/mac80211/spectmgmt.c                     |    4 +-
 net/mac80211/sta_info.c                      |   32 ++--
 net/mac80211/sta_info.h                      |   29 +++-
 net/mac80211/status.c                        |   46 ++++-
 net/mac80211/tkip.c                          |   38 ++--
 net/mac80211/tx.c                            |   42 ++--
 net/mac80211/util.c                          |  104 ++++++++-
 net/wireless/.gitignore                      |    1 +
 net/wireless/Kconfig                         |   16 ++
 net/wireless/Makefile                        |    6 +
 net/wireless/core.h                          |    2 +
 net/wireless/db.txt                          |   17 ++
 net/wireless/genregdb.awk                    |  118 ++++++++++
 net/wireless/mlme.c                          |   11 +-
 net/wireless/nl80211.c                       |   37 +---
 net/wireless/reg.c                           |  120 +++++++++--
 net/wireless/regdb.h                         |    7 +
 net/wireless/util.c                          |  132 +++++++++++-
 net/wireless/wext-compat.c                   |    5 +-
 117 files changed, 2965 insertions(+), 1122 deletions(-)
 create mode 100644 net/wireless/.gitignore
 create mode 100644 net/wireless/db.txt
 create mode 100644 net/wireless/genregdb.awk
 create mode 100644 net/wireless/regdb.h

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2009-12-24.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
