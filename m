From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211-next 2016-04-13
Date: Wed, 13 Apr 2016 21:36:31 +0200
Message-ID: <1460576192-24712-1-git-send-email-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:38314 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752409AbcDMTgk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 15:36:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

For a while now I've wanted to remove enum ieee80211_band, and in
order to synchronize more easily with Kalle that's (apart from a
documentation change I already had pending) all in this pull.

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit bddf59046d804638d998f9015246d4990f1cab09:

  Merge tag 'wireless-drivers-next-for-davem-2016-04-11' of git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next (2016-04-11 11:58:12 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2016-04-13

for you to fetch changes up to 57fbcce37be7c1d2622b56587c10ade00e96afa3:

  cfg80211: remove enum ieee80211_band (2016-04-12 15:56:15 +0200)

----------------------------------------------------------------
To synchronize with Kalle, here's just a big change that affects
all drivers - removing the duplicated enum ieee80211_band and
replacing it by enum nl80211_band. On top of that, just a small
documentation update.

----------------------------------------------------------------
Johannes Berg (1):
      cfg80211: remove enum ieee80211_band

Jouni Malinen (1):
      cfg80211: Improve Connect/Associate command documentation

 Documentation/DocBook/80211.tmpl                   |   1 -
 drivers/net/wireless/admtek/adm8211.c              |   4 +-
 drivers/net/wireless/ath/ar5523/ar5523.c           |   4 +-
 drivers/net/wireless/ath/ath.h                     |   2 +-
 drivers/net/wireless/ath/ath10k/core.h             |   2 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |   8 +-
 drivers/net/wireless/ath/ath10k/mac.c              |  68 ++++----
 drivers/net/wireless/ath/ath10k/wmi.c              |   8 +-
 drivers/net/wireless/ath/ath5k/ani.c               |   2 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |  10 +-
 drivers/net/wireless/ath/ath5k/attach.c            |   8 +-
 drivers/net/wireless/ath/ath5k/base.c              |  32 ++--
 drivers/net/wireless/ath/ath5k/debug.c             |   6 +-
 drivers/net/wireless/ath/ath5k/pcu.c               |   6 +-
 drivers/net/wireless/ath/ath5k/phy.c               |  30 ++--
 drivers/net/wireless/ath/ath5k/qcu.c               |   8 +-
 drivers/net/wireless/ath/ath5k/reset.c             |   6 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |  22 +--
 drivers/net/wireless/ath/ath6kl/core.h             |   2 +-
 drivers/net/wireless/ath/ath6kl/wmi.c              |  22 +--
 drivers/net/wireless/ath/ath6kl/wmi.h              |   2 +-
 drivers/net/wireless/ath/ath9k/calib.c             |   6 +-
 drivers/net/wireless/ath/ath9k/channel.c           |   8 +-
 drivers/net/wireless/ath/ath9k/common-init.c       |  28 ++--
 drivers/net/wireless/ath/ath9k/common.c            |   4 +-
 drivers/net/wireless/ath/ath9k/debug_sta.c         |   6 +-
 drivers/net/wireless/ath/ath9k/dynack.c            |   2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   8 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |  12 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |   2 +-
 drivers/net/wireless/ath/ath9k/init.c              |  12 +-
 drivers/net/wireless/ath/ath9k/main.c              |   4 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |   4 +-
 drivers/net/wireless/ath/carl9170/mac.c            |  12 +-
 drivers/net/wireless/ath/carl9170/main.c           |   6 +-
 drivers/net/wireless/ath/carl9170/phy.c            |  18 +--
 drivers/net/wireless/ath/carl9170/rx.c             |   2 +-
 drivers/net/wireless/ath/carl9170/tx.c             |   8 +-
 drivers/net/wireless/ath/regd.c                    |  16 +-
 drivers/net/wireless/ath/regd.h                    |   2 +-
 drivers/net/wireless/ath/wcn36xx/main.c            |  12 +-
 drivers/net/wireless/ath/wcn36xx/smd.c             |   4 +-
 drivers/net/wireless/ath/wcn36xx/txrx.c            |   2 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |   4 +-
 drivers/net/wireless/ath/wil6210/netdev.c          |   2 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |   2 +-
 drivers/net/wireless/atmel/at76c50x-usb.c          |   6 +-
 drivers/net/wireless/atmel/atmel.c                 |   2 +-
 drivers/net/wireless/broadcom/b43/b43.h            |   4 +-
 drivers/net/wireless/broadcom/b43/main.c           |  34 ++--
 drivers/net/wireless/broadcom/b43/phy_ac.c         |   2 +-
 drivers/net/wireless/broadcom/b43/phy_common.c     |   2 +-
 drivers/net/wireless/broadcom/b43/phy_ht.c         |  16 +-
 drivers/net/wireless/broadcom/b43/phy_lcn.c        |  10 +-
 drivers/net/wireless/broadcom/b43/phy_lp.c         |  30 ++--
 drivers/net/wireless/broadcom/b43/phy_n.c          | 176 ++++++++++-----------
 drivers/net/wireless/broadcom/b43/tables_lpphy.c   |  14 +-
 drivers/net/wireless/broadcom/b43/tables_nphy.c    |  16 +-
 drivers/net/wireless/broadcom/b43/tables_phy_lcn.c |   2 +-
 drivers/net/wireless/broadcom/b43/xmit.c           |   8 +-
 drivers/net/wireless/broadcom/b43legacy/main.c     |  12 +-
 drivers/net/wireless/broadcom/b43legacy/xmit.c     |   2 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |  74 ++++-----
 .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.c |   8 +-
 .../wireless/broadcom/brcm80211/brcmsmac/channel.c |  10 +-
 .../broadcom/brcm80211/brcmsmac/mac80211_if.c      |  16 +-
 .../wireless/broadcom/brcm80211/brcmsmac/main.c    |   4 +-
 drivers/net/wireless/cisco/airo.c                  |   6 +-
 drivers/net/wireless/intel/ipw2x00/ipw2100.c       |   6 +-
 drivers/net/wireless/intel/ipw2x00/ipw2200.c       |  12 +-
 drivers/net/wireless/intel/iwlegacy/3945-mac.c     |  30 ++--
 drivers/net/wireless/intel/iwlegacy/3945-rs.c      |  22 +--
 drivers/net/wireless/intel/iwlegacy/3945.c         |  20 +--
 drivers/net/wireless/intel/iwlegacy/4965-mac.c     |  38 ++---
 drivers/net/wireless/intel/iwlegacy/4965-rs.c      |  22 +--
 drivers/net/wireless/intel/iwlegacy/4965.c         |   6 +-
 drivers/net/wireless/intel/iwlegacy/4965.h         |   2 +-
 drivers/net/wireless/intel/iwlegacy/common.c       |  70 ++++----
 drivers/net/wireless/intel/iwlegacy/common.h       |  30 ++--
 drivers/net/wireless/intel/iwlegacy/debug.c        |   4 +-
 drivers/net/wireless/intel/iwlwifi/dvm/agn.h       |   8 +-
 drivers/net/wireless/intel/iwlwifi/dvm/debugfs.c   |   4 +-
 drivers/net/wireless/intel/iwlwifi/dvm/dev.h       |   6 +-
 drivers/net/wireless/intel/iwlwifi/dvm/devices.c   |   4 +-
 drivers/net/wireless/intel/iwlwifi/dvm/lib.c       |   6 +-
 drivers/net/wireless/intel/iwlwifi/dvm/mac80211.c  |  12 +-
 drivers/net/wireless/intel/iwlwifi/dvm/main.c      |   4 +-
 drivers/net/wireless/intel/iwlwifi/dvm/rs.c        |  22 +--
 drivers/net/wireless/intel/iwlwifi/dvm/rs.h        |   2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/rx.c        |   2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/rxon.c      |  10 +-
 drivers/net/wireless/intel/iwlwifi/dvm/scan.c      |  38 ++---
 drivers/net/wireless/intel/iwlwifi/dvm/sta.c       |   2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/tx.c        |   4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-1000.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-2000.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-5000.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-6000.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-7000.c      |   4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-9000.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |   2 +-
 .../net/wireless/intel/iwlwifi/iwl-eeprom-parse.c  |  38 ++---
 .../net/wireless/intel/iwlwifi/iwl-eeprom-parse.h  |   6 +-
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c |  26 +--
 drivers/net/wireless/intel/iwlwifi/mvm/coex.c      |  10 +-
 .../net/wireless/intel/iwlwifi/mvm/debugfs-vif.c   |   6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |   8 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |  16 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |   6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/phy-ctxt.c  |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c        |  28 ++--
 drivers/net/wireless/intel/iwlwifi/mvm/rs.h        |   4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rx.c        |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |   4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |  36 ++---
 drivers/net/wireless/intel/iwlwifi/mvm/tdls.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |   6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c     |   4 +-
 drivers/net/wireless/intersil/orinoco/cfg.c        |   6 +-
 drivers/net/wireless/intersil/orinoco/hw.c         |   2 +-
 drivers/net/wireless/intersil/orinoco/scan.c       |   4 +-
 drivers/net/wireless/intersil/p54/eeprom.c         |  32 ++--
 drivers/net/wireless/intersil/p54/main.c           |   4 +-
 drivers/net/wireless/intersil/p54/p54.h            |   2 +-
 drivers/net/wireless/intersil/p54/txrx.c           |   4 +-
 drivers/net/wireless/mac80211_hwsim.c              |  14 +-
 drivers/net/wireless/marvell/libertas/cfg.c        |  10 +-
 drivers/net/wireless/marvell/libertas/cmd.c        |   4 +-
 drivers/net/wireless/marvell/libertas_tf/main.c    |   4 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |  34 ++--
 drivers/net/wireless/marvell/mwifiex/cfp.c         |  12 +-
 drivers/net/wireless/marvell/mwifiex/scan.c        |   8 +-
 drivers/net/wireless/marvell/mwifiex/uap_cmd.c     |   2 +-
 drivers/net/wireless/marvell/mwl8k.c               |  88 +++++------
 drivers/net/wireless/mediatek/mt7601u/init.c       |   4 +-
 drivers/net/wireless/ralink/rt2x00/rt2800lib.c     |  30 ++--
 drivers/net/wireless/ralink/rt2x00/rt2x00.h        |   4 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00dev.c     |  40 ++---
 drivers/net/wireless/ralink/rt2x00/rt61pci.c       |  22 +--
 drivers/net/wireless/ralink/rt2x00/rt73usb.c       |  22 +--
 drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c |   8 +-
 drivers/net/wireless/realtek/rtl818x/rtl8187/dev.c |   4 +-
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c   |  30 ++--
 drivers/net/wireless/realtek/rtlwifi/base.c        |  44 +++---
 drivers/net/wireless/realtek/rtlwifi/regd.c        |  16 +-
 drivers/net/wireless/realtek/rtlwifi/wifi.h        |   2 +-
 drivers/net/wireless/rndis_wlan.c                  |   4 +-
 drivers/net/wireless/rsi/rsi_91x_mac80211.c        | 100 ++++++------
 drivers/net/wireless/rsi/rsi_91x_mgmt.c            |   8 +-
 drivers/net/wireless/rsi/rsi_91x_pkt.c             |   2 +-
 drivers/net/wireless/rsi/rsi_main.h                |   2 +-
 drivers/net/wireless/st/cw1200/main.c              |  10 +-
 drivers/net/wireless/st/cw1200/scan.c              |   2 +-
 drivers/net/wireless/st/cw1200/sta.c               |   6 +-
 drivers/net/wireless/st/cw1200/txrx.c              |   2 +-
 drivers/net/wireless/st/cw1200/wsm.c               |   4 +-
 drivers/net/wireless/ti/wl1251/main.c              |   2 +-
 drivers/net/wireless/ti/wl1251/rx.c                |   2 +-
 drivers/net/wireless/ti/wl12xx/main.c              |   8 +-
 drivers/net/wireless/ti/wl12xx/scan.c              |  20 +--
 drivers/net/wireless/ti/wl18xx/cmd.c               |   6 +-
 drivers/net/wireless/ti/wl18xx/event.c             |   6 +-
 drivers/net/wireless/ti/wl18xx/main.c              |  22 +--
 drivers/net/wireless/ti/wl18xx/scan.c              |   8 +-
 drivers/net/wireless/ti/wl18xx/tx.c                |   2 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |  36 ++---
 drivers/net/wireless/ti/wlcore/cmd.h               |   6 +-
 drivers/net/wireless/ti/wlcore/main.c              |  32 ++--
 drivers/net/wireless/ti/wlcore/ps.c                |   4 +-
 drivers/net/wireless/ti/wlcore/rx.c                |   4 +-
 drivers/net/wireless/ti/wlcore/rx.h                |   2 +-
 drivers/net/wireless/ti/wlcore/scan.c              |  14 +-
 drivers/net/wireless/ti/wlcore/tx.c                |   2 +-
 drivers/net/wireless/ti/wlcore/tx.h                |   4 +-
 drivers/net/wireless/ti/wlcore/wlcore.h            |   4 +-
 drivers/net/wireless/ti/wlcore/wlcore_i.h          |   2 +-
 drivers/net/wireless/wl3501_cs.c                   |   2 +-
 drivers/net/wireless/zydas/zd1211rw/zd_mac.c       |   4 +-
 drivers/staging/rtl8723au/core/rtw_mlme_ext.c      |   4 +-
 drivers/staging/rtl8723au/include/ieee80211.h      |   2 +-
 drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c  |  54 +++----
 drivers/staging/vt6655/channel.c                   |   4 +-
 drivers/staging/vt6655/device_main.c               |   4 +-
 drivers/staging/vt6655/rxtx.c                      |   2 +-
 drivers/staging/vt6656/channel.c                   |   4 +-
 drivers/staging/vt6656/int.c                       |   2 +-
 drivers/staging/vt6656/main_usb.c                  |   2 +-
 drivers/staging/vt6656/rxtx.c                      |   2 +-
 drivers/staging/wilc1000/wilc_wfi_cfgoperations.c  |  10 +-
 drivers/staging/wlan-ng/cfg80211.c                 |   6 +-
 include/net/cfg80211.h                             |  70 ++++----
 include/net/mac80211.h                             |  12 +-
 include/uapi/linux/nl80211.h                       |  20 ++-
 net/mac80211/cfg.c                                 |  14 +-
 net/mac80211/debugfs_netdev.c                      |  12 +-
 net/mac80211/ibss.c                                |  10 +-
 net/mac80211/ieee80211_i.h                         |  34 ++--
 net/mac80211/iface.c                               |   2 +-
 net/mac80211/main.c                                |   6 +-
 net/mac80211/mesh.c                                |  10 +-
 net/mac80211/mesh_plink.c                          |  10 +-
 net/mac80211/mlme.c                                |  14 +-
 net/mac80211/rate.c                                |   2 +-
 net/mac80211/rc80211_minstrel.c                    |   6 +-
 net/mac80211/rc80211_minstrel_ht.c                 |   4 +-
 net/mac80211/rx.c                                  |   6 +-
 net/mac80211/scan.c                                |  12 +-
 net/mac80211/spectmgmt.c                           |   4 +-
 net/mac80211/tdls.c                                |  18 +--
 net/mac80211/trace.h                               |   6 +-
 net/mac80211/tx.c                                  |  14 +-
 net/mac80211/util.c                                |  24 +--
 net/mac80211/vht.c                                 |   4 +-
 net/wireless/chan.c                                |   2 +-
 net/wireless/core.c                                |   8 +-
 net/wireless/debugfs.c                             |   4 +-
 net/wireless/ibss.c                                |   6 +-
 net/wireless/mesh.c                                |   4 +-
 net/wireless/mlme.c                                |   2 +-
 net/wireless/nl80211.c                             |  44 +++---
 net/wireless/rdev-ops.h                            |   2 +-
 net/wireless/reg.c                                 |  30 ++--
 net/wireless/reg.h                                 |   2 +-
 net/wireless/scan.c                                |  14 +-
 net/wireless/sme.c                                 |   6 +-
 net/wireless/trace.h                               |  20 +--
 net/wireless/util.c                                |  40 ++---
 net/wireless/wext-compat.c                         |  14 +-
 230 files changed, 1456 insertions(+), 1443 deletions(-)
