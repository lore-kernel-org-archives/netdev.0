From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2010-03-29
Date: Mon, 29 Mar 2010 16:13:19 -0400
Message-ID: <20100329201319.GJ4984@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Another dump of stuff intended for 2.6.35...nothing too unusual, mostly
driver updates and some random cleanups.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 30bde1f5076a9b6bd4b6a168523930ce242c7449:
  Stephen Rothwell (1):
        rps: fix net-sysfs build for !CONFIG_RPS

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Amitkumar Karwar (1):
      libertas: add auto auth mode feature

Ben M Cahill (1):
      iwlagn: Add Flow-handler (FH) register dump for 4965.

Dan Carpenter (1):
      mac80211: remove unneed variable from ieee80211_tx_pending()

Daniel Ngu (1):
      drivers/net/wireless/b43/main.c:4351: Fixed coding style

Joe Perches (8):
      include/linux/wireless.h: Add IW_HANDLER macro to initialize array entry
      wireless.h: Use SIOCIWFIRST not SIOCSIWCOMMIT for range check
      net/wireless/wext_core.c: Use IW_IOCTL_IDX macro
      net/wireless/wext-core.c: Use IW_EVENT_IDX macro
      drivers/net/wireless: Use IW_HANDLER macro
      drivers/net: Remove local #define IW_IOCTL, use IW_HANDLER
      orinoco/wext.c: Remove local #define STD_IW_HANDLER
      drivers/net/wireless/ray_cs.c: Use iw_handler function prototypes

Johannes Berg (1):
      iwlwifi: sta_id cannot be invalid in rs_initialize_lq

John W. Linville (2):
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlwifi/iwlwifi-2.6
      iwlwifi: fix build error for CONFIG_IWLAGN=n

Juuso Oikarinen (14):
      wl1271: Fix configuration of the TX opportunity value
      wl1271: Fix SG configuration message structures
      wl1271: Add proper WLAN-BT co-ex configuration, and enable co-ex.
      wl1271: Move platform device registration from _spi to _main
      wl1271: Add sysfs file to control BT co-ex state
      wl1271: Fix MAC address handling
      wl1271: Remove deprecated interface config function
      wl1271: Update filters properly
      wl1271: Don't generate null func template for ad-hoc
      wl1271: Remove circular interlocking related to the inetaddr notifier chain
      mac80211: Add support for connection monitor in hardware
      cfg80211: Add connection quality monitoring support to nl80211
      mac80211: Add support for connection quality monitoring
      cfg80211: Improve connection quality maintenance docs in nl80211.h

Kalle Valo (6):
      wl1271: enable WMM
      wl1271: get pspoll and nullfunc templates from mac80211
      wl1271: get probe request template from mac80211
      wl1271: create qos nullfunc template
      wl1271: fix ps scheme in wl1271_op_conf_tx()
      wl1271: enable U-APSD

Ming Lei (1):
      ath9k: decrease size of ath9k.ko

Reinette Chatre (2):
      iwlwifi: only add broadcast station once
      iwlwifi: implement new mac80211 station add/remove calls

Shanyu Zhao (1):
      iwlwifi: clean up driver names for 1000/5000/6000

Sujith (13):
      ath9k_hw: update initialization values for AR9271
      ath9k_hw: add GPIO setup code for AR9271
      ath9k_hw: skip chip tests for AR9271
      ath9k_hw: fix TX descriptor setup for AR9271
      ath9k_hw: Fix full sleep setup for AR9271
      ath9k_hw: fix noisefloor history buffer usage on AR9271
      ath9k_hw: restrict valid nf readings for AR9271 to -114
      ath9k_hw: use the skip count for PA calibration on AR9271
      ath9k_hw: always set the core clock for AR9271
      ath9k_hw: add HTC init hardware call for special resets for AR9271
      ath9k_hw: fix hardware deinit
      ath9k_htc: Support for AR9271 chipset.
      ath9k_htc: Fix symbol collision with ath9k

Teemu Paasikivi (5):
      wl1271: Cleaned up wlan power on/off functions
      wl1271: Changed SDIO MMC host claiming
      wl1271: Added DEBUG_SDIO flag
      wl1271: Removed duplicate code from module remove function.
      wl1271: Changed platform_device to be dynamically allocated

Wey-Yi Guy (4):
      iwlwifi: Recover TX flow stall due to stuck queue
      iwlwifi: move plcp check to separated function
      iwlwifi: Recover TX flow failure
      iwlwifi: code cleanup for connectivity recovery

 drivers/net/ps3_gelic_wireless.c                |   35 +-
 drivers/net/wireless/ath/Kconfig                |    2 +-
 drivers/net/wireless/ath/ath9k/Kconfig          |   21 +
 drivers/net/wireless/ath/ath9k/Makefile         |   10 +
 drivers/net/wireless/ath/ath9k/calib.c          |   25 +-
 drivers/net/wireless/ath/ath9k/common.c         |  421 ++++++
 drivers/net/wireless/ath/ath9k/common.h         |   17 +
 drivers/net/wireless/ath/ath9k/hif_usb.c        |  993 ++++++++++++++
 drivers/net/wireless/ath/ath9k/hif_usb.h        |  105 ++
 drivers/net/wireless/ath/ath9k/htc.h            |  441 ++++++
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c |  260 ++++
 drivers/net/wireless/ath/ath9k/htc_drv_init.c   |  713 ++++++++++
 drivers/net/wireless/ath/ath9k/htc_drv_main.c   | 1626 +++++++++++++++++++++++
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c   |  604 +++++++++
 drivers/net/wireless/ath/ath9k/htc_hst.c        |  463 +++++++
 drivers/net/wireless/ath/ath9k/htc_hst.h        |  246 ++++
 drivers/net/wireless/ath/ath9k/hw.c             |  134 +-
 drivers/net/wireless/ath/ath9k/hw.h             |    8 +
 drivers/net/wireless/ath/ath9k/init.c           |    3 +
 drivers/net/wireless/ath/ath9k/initvals.h       |  141 ++-
 drivers/net/wireless/ath/ath9k/mac.c            |    2 +-
 drivers/net/wireless/ath/ath9k/mac.h            |   26 +
 drivers/net/wireless/ath/ath9k/rc.h             |    4 +-
 drivers/net/wireless/ath/ath9k/reg.h            |    3 +
 drivers/net/wireless/ath/ath9k/wmi.c            |  319 +++++
 drivers/net/wireless/ath/ath9k/wmi.h            |  126 ++
 drivers/net/wireless/ath/debug.h                |    1 +
 drivers/net/wireless/b43/main.c                 |    5 +-
 drivers/net/wireless/ipw2x00/ipw2200.c          |   83 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c         |    9 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c      |   83 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c         |   22 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h         |    1 -
 drivers/net/wireless/iwlwifi/iwl-4965.c         |    5 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c         |   28 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c         |   24 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c       |  124 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h       |    7 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c          |  154 ++-
 drivers/net/wireless/iwlwifi/iwl-core.c         |  102 ++-
 drivers/net/wireless/iwlwifi/iwl-core.h         |   19 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h          |   23 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c           |  155 ++-
 drivers/net/wireless/iwlwifi/iwl-sta.c          |  630 ++++++----
 drivers/net/wireless/iwlwifi/iwl-sta.h          |   20 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c           |    2 +
 drivers/net/wireless/iwlwifi/iwl3945-base.c     |   72 +-
 drivers/net/wireless/libertas/assoc.c           |   22 +-
 drivers/net/wireless/libertas/dev.h             |    1 +
 drivers/net/wireless/libertas/main.c            |    1 +
 drivers/net/wireless/libertas/wext.c            |    4 +
 drivers/net/wireless/orinoco/wext.c             |   94 +-
 drivers/net/wireless/ray_cs.c                   |  212 ++--
 drivers/net/wireless/wl12xx/wl1271.h            |    7 +
 drivers/net/wireless/wl12xx/wl1271_acx.c        |   25 +-
 drivers/net/wireless/wl12xx/wl1271_acx.h        |   68 +-
 drivers/net/wireless/wl12xx/wl1271_boot.c       |    8 +
 drivers/net/wireless/wl12xx/wl1271_cmd.c        |  218 ++--
 drivers/net/wireless/wl12xx/wl1271_cmd.h        |   12 +-
 drivers/net/wireless/wl12xx/wl1271_conf.h       |  330 ++++-
 drivers/net/wireless/wl12xx/wl1271_debugfs.c    |   12 +-
 drivers/net/wireless/wl12xx/wl1271_event.c      |    2 +
 drivers/net/wireless/wl12xx/wl1271_init.c       |    4 +-
 drivers/net/wireless/wl12xx/wl1271_io.h         |   13 +
 drivers/net/wireless/wl12xx/wl1271_main.c       |  496 +++++---
 drivers/net/wireless/wl12xx/wl1271_sdio.c       |   74 +-
 drivers/net/wireless/wl12xx/wl1271_spi.c        |   35 +-
 drivers/net/wireless/wl12xx/wl1271_tx.h         |    3 -
 drivers/net/wireless/wl3501_cs.c                |   52 +-
 include/linux/nl80211.h                         |   50 +
 include/linux/wireless.h                        |    4 +-
 include/net/cfg80211.h                          |   19 +
 include/net/mac80211.h                          |   54 +-
 net/mac80211/cfg.c                              |   27 +
 net/mac80211/ieee80211_i.h                      |    4 +-
 net/mac80211/iface.c                            |    2 +-
 net/mac80211/mlme.c                             |   79 +-
 net/mac80211/tx.c                               |    2 -
 net/wireless/mlme.c                             |   13 +
 net/wireless/nl80211.c                          |  131 ++
 net/wireless/nl80211.h                          |    6 +
 net/wireless/wext-core.c                        |  134 +-
 82 files changed, 9032 insertions(+), 1503 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/hif_usb.c
 create mode 100644 drivers/net/wireless/ath/ath9k/hif_usb.h
 create mode 100644 drivers/net/wireless/ath/ath9k/htc.h
 create mode 100644 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c
 create mode 100644 drivers/net/wireless/ath/ath9k/htc_drv_init.c
 create mode 100644 drivers/net/wireless/ath/ath9k/htc_drv_main.c
 create mode 100644 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
 create mode 100644 drivers/net/wireless/ath/ath9k/htc_hst.c
 create mode 100644 drivers/net/wireless/ath/ath9k/htc_hst.h
 create mode 100644 drivers/net/wireless/ath/ath9k/wmi.c
 create mode 100644 drivers/net/wireless/ath/ath9k/wmi.h

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2010-03-29.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
