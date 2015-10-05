From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211-next 2015-10-05
Date: Mon, 05 Oct 2015 18:01:11 +0200
Message-ID: <1444060871.14787.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:57431 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750761AbbJEQBO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2015 12:01:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Somehow I let this slide, I probably should've sent it earlier, sorry
about that.

On the other hand, we don't have all that much content, at least it
feels much less than usual.

Please pull, and let me know if there are any problems.

Thanks,
johannes

The following changes since commit 395250e483d492e9ec5e36a6b78fb142affd=
dee2:

  Merge tag 'wireless-drivers-next-for-davem-2015-08-26' of git://git.k=
ernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next (2015-08=
-27 11:25:56 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git=
 tags/mac80211-next-for-davem-2015-10-05

for you to fetch changes up to 5edfcee5ed73eb9537987c4ddb6bf062b6943b73=
:

  mac80211: make ieee80211_new_mesh_header return unsigned (2015-10-05 =
17:54:16 +0200)

----------------------------------------------------------------
=46or the current cycle, we have the following right now:
 * many internal fixes, API improvements, cleanups, etc.
 * full AP client state tracking in cfg80211/mac80211 from Ayala
 * VHT support (in mac80211) for mesh
 * some A-MSDU in A-MPDU support from Emmanuel
 * show current TX power to userspace (from Rafa=C5=82)
 * support for netlink dump in vendor commands (myself)

----------------------------------------------------------------
Andrei Otcheretianski (2):
      mac80211: process skb_queue while scanning in HW
      mac80211: introduce per vif frame registration API

Andrzej Hajda (1):
      mac80211: make ieee80211_new_mesh_header return unsigned

Arik Nemtsov (2):
      mac80211: debugfs: add file to disallow TDLS wider-bw
      mac80211: TDLS: check reg with IR-relax on chandef upgrade

Ayala Beker (2):
      cfg80211: allow changing station capabilities for unassociated st=
ations
      mac80211: advertise support for full station state in AP mode

Bob Copeland (1):
      mac80211: implement VHT support for mesh

Chun-Yeow Yeoh (1):
      mac80211: zero center freq segment 2 in VHT oper IE

Denys Vlasenko (6):
      mac80211: Deinline drv_conf_tx()
      mac80211: Deinline drv_sta_rc_update()
      mac80211: Deinline drv_add/remove/change_interface()
      mac80211: Deinline drv_switch_vif_chanctx()
      mac80211: Deinline drv_ampdu_action()
      mac80211: Deinline drv_get/set/reset_tsf()

Eliad Peller (1):
      mac80211: don't tear down aggregation on suspend in case of wowla=
n->any

Emmanuel Grumbach (2):
      mac80211: allow to transmit A-MSDU within A-MPDU
      mac80211: allow the driver to advertise A-MSDU within A-MPDU Rx s=
upport

=46elix Fietkau (1):
      mac80211: fix tx sequence number assignment with software queue +=
 fast-xmit

=46u, Zhonghui (1):
      net/wireless: enable wiphy device to suspend/resume asynchronousl=
y

Helmut Schaa (2):
      mac80211: Split sending tx'ed frames to monitor interfaces into i=
ts own function
      mac80211: Copy tx'ed beacons to monitor mode

Johannes Berg (13):
      wireless: make __freq_reg_info static
      nl80211: support vendor dumpit commands
      mac80211: remove direct probe step before authentication
      mac80211: remove last_beacon/ave_beacon debugfs files
      mac80211: fix driver RSSI event calculations
      mac80211: use DECLARE_EWMA for ave_beacon_signal
      wireless: mark element IDs 8 and 9 reserved
      Revert "mac80211: add pointer for driver use to key"
      mac80211: minstrel[_ht]: remove non-ascii debugfs characters
      mac80211: improve __rate_control_send_low warning
      mac80211: allow writing TX PN in debugfs
      mac80211: reduce indentation by inlining a check
      mac80211: use bool argument to ieee80211_send_nullfunc

Rafa=C5=82 Mi=C5=82ecki (1):
      nl80211: put current TX power in interface info

 drivers/net/wireless/ath/ath10k/mac.c              |   2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   2 +-
 drivers/net/wireless/ath/ath9k/main.c              |   2 +-
 drivers/net/wireless/ath/carl9170/main.c           |   2 +-
 drivers/net/wireless/ath/wcn36xx/main.c            |   2 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   2 +-
 drivers/net/wireless/cw1200/sta.c                  |   2 +-
 drivers/net/wireless/cw1200/sta.h                  |   2 +-
 drivers/net/wireless/ipw2x00/libipw_rx.c           |   2 -
 drivers/net/wireless/iwlegacy/4965-mac.c           |   2 +-
 drivers/net/wireless/iwlegacy/4965.h               |   2 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |   2 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |   2 +-
 drivers/net/wireless/mac80211_hwsim.c              |   2 +-
 drivers/net/wireless/mediatek/mt7601u/main.c       |   3 +-
 drivers/net/wireless/mwl8k.c                       |   2 +-
 drivers/net/wireless/rsi/rsi_91x_mac80211.c        |   4 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |   2 +-
 drivers/net/wireless/rt2x00/rt2800lib.h            |   2 +-
 drivers/net/wireless/rtlwifi/core.c                |   2 +-
 drivers/net/wireless/ti/wlcore/main.c              |   2 +-
 include/linux/ieee80211.h                          |   4 +-
 include/net/cfg80211.h                             |  12 +
 include/net/mac80211.h                             |  31 ++-
 net/mac80211/agg-rx.c                              |   8 +-
 net/mac80211/agg-tx.c                              |  15 +-
 net/mac80211/cfg.c                                 |  56 +++--
 net/mac80211/debugfs.c                             |   2 +
 net/mac80211/debugfs_key.c                         |  51 +++-
 net/mac80211/debugfs_netdev.c                      |  41 +++-
 net/mac80211/driver-ops.c                          | 222 +++++++++++++=
+++++
 net/mac80211/driver-ops.h                          | 259 ++++---------=
--------
 net/mac80211/ieee80211_i.h                         |  19 +-
 net/mac80211/iface.c                               |   2 +-
 net/mac80211/main.c                                |   3 +-
 net/mac80211/mesh.c                                |  82 ++++++-
 net/mac80211/mesh.h                                |  10 +-
 net/mac80211/mesh_plink.c                          |   9 +-
 net/mac80211/mlme.c                                | 155 +++++-------
 net/mac80211/offchannel.c                          |   6 +-
 net/mac80211/pm.c                                  |   3 +-
 net/mac80211/rate.c                                |   5 +-
 net/mac80211/rc80211_minstrel_debugfs.c            |  12 +-
 net/mac80211/rc80211_minstrel_ht_debugfs.c         |  12 +-
 net/mac80211/sta_info.h                            |   2 +
 net/mac80211/status.c                              | 108 +++++----
 net/mac80211/tdls.c                                |   8 +-
 net/mac80211/trace.h                               |  40 +++-
 net/mac80211/tx.c                                  |  22 +-
 net/mac80211/util.c                                |  11 +-
 net/wireless/core.c                                |   1 +
 net/wireless/nl80211.c                             | 209 +++++++++++++=
+++-
 net/wireless/reg.c                                 |   4 +-
 53 files changed, 981 insertions(+), 488 deletions(-)
