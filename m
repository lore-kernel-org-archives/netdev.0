From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2010-07-01
Date: Thu, 1 Jul 2010 14:15:27 -0400
Message-ID: <20100701181526.GA2356@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David,

Two weeks since the last request, plenty of new stuff intended for
2.6.36...

Included are the usual bunch of driver updates, including a big
dump from the rt2x00 team.  This also includes cfg80211 support
for libertas, a flurry of (mostly trivial) stuff from me, and a
wireless-2.6 pull to resolve some patch dependencies.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit ea812ca1b06113597adcd8e70c0f84a413d9=
7544:
  Alexander Duyck (1):
        x86: Align skb w/ start of cacheline on newer core 2/Xeon Arch

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Bruno Randolf (1):
      ath5k: fix antenna div gc for <=3D AR5K_SREV_PHY_2413

Daniel Halperin (1):
      iwlwifi: update LQ for bcast station on channel change

=46elix Fietkau (3):
      ath9k: fix retry count for A-MPDU rate control status reports
      mac80211: fix the for_each_sta_info macro
      ath9k: fix TSF after reset on AR913x

Gertjan van Wingerde (10):
      mac80211: Fix compile warning in scan.c.
      rt2x00: Fix frame dumping for USB devices.
      rt2x00: Move filling of TX URB to rt2x00usb_kick_tx_entry functio=
n.
      rt2x00: Merge PCI and USB versions of write_tx_data into single f=
unction.
      rt2x00: Move common txdone handling to rt2x00lib_txdone.
      rt2x00: Rename driver write_tx_datadesc callback function.
      rt2x00: Split of TXWI writing to write_tx_data callback in rt2800=
usb.
      eeprom_93cx6: Add support for 93c86 EEPROMs.
      rt2x00: Correctly detect 93C86 EEPROMs in rt2800pci.
      rt2x00: Align rt2800 EEPROM validation to Ralink vendor driver.

Helmut Schaa (6):
      rt2x00: Implement tx mpdu aggregation
      rt2x00: Fix beacon updates in rt2800pci
      rt2x00: Fix beacon updates in rt61pci
      rt2x00: Disable link tuning in AP mode
      rt2x00: fix beacon reset on rt2800
      mac82011: Allow selection of minstrel_ht as default rc algorithm

Ivo van Doorn (7):
      rt2x00: Write the BSSID to register when interface is added
      rt2x00: Remove unneeded variable
      rt2x00: Enable multiBSS in rt2800
      rt2x00: Fix IEEE80211_HT_CAP_RX_STBC assignment
      rt2x00: Fix antenna initialization
      rt2x00: Always set BBP_CSR_CFG_BBP_RW_MODE to 1
      rt2x00: Fix compile warning when debug disabled

Jay Sternberg (1):
      iwlwifi: display ucode SW Error in hex

Johannes Berg (7):
      mac80211_hwsim: fix fake_hw_scan
      mac80211: fix sw scan bracketing
      iwlagn: use mutex for aggregation
      iwlwifi: use sync commands for keys
      iwlwifi: return ucode errors from station management
      iwlwifi: fix multicast
      iwlwifi: read rfkill during resume

John W. Linville (14):
      libertas: mark lbs_ret_802_11d_domain_info static
      ath9k: declare MODULE_FIRMWARE for ath9k_htc
      rtl8180: mark rtl8180_beacon_work static
      mac80211: don't shadow mgmt variable in ieee80211_rx_h_action
      minstrel_ht: make *idx unsigned in minstrel_downgrade_rate
      wireless: mark reg_mutex as static
      minstrel_ht: move minstrel_mcs_groups declaration to header file
      mac80211: avoid scheduling while atomic in mesh_rx_plink_frame
      mac80211: use netif_receive_skb in ieee80211_rx callpath
      mac80211: use netif_receive_skb in ieee80211_tx_status callpath
      mac80211: remove unnecessary check in ieee80211_dump_survey
      mac80211: add basic tracing to drv_get_survey
      ath9k: remove unused function ath9k_hw_keyisvalid
      ath9k: make ath9k_hw_keysetmac static

Justin P. Mattock (2):
      wireless:hostap_main.c warning: variable 'iface' set but not used
      wireless:hostap_ap.c Fix warning: variable 'fc' set but not used

Juuso Oikarinen (3):
      mac80211: Add interface for driver to temporarily disable dynamic=
 ps
      cfg80211/mac80211: Update set_tx_power to use mBm instead of dBm =
units
      nl80211: Add option to adjust transmit power

Kiran Divekar (3):
      Libertas: cfg80211 support
      Libertas: fix WARN_ON issues in cfg80211 support
      Libertas: Added 11d support using cfg80211

Larry Finger (1):
      b43: Clarify logged message after fatal DMA error and switch to P=
IO mode

Luis R. Rodriguez (5):
      ath9k_hw: fix ASPM setting for AR9003
      ath9k_hw: move LowPower array writes to ar9003_hw_configpcipowers=
ave()
      ath9k_hw: add pcieSerDesWrite to disable SERDES ASPM tweaks
      ath9k_hw: dynamically choose the SERDES array for low power
      ath9k_hw: add an extra delay when reseting AR_RTC_RESET

Magnus Damm (1):
      b43: Add SDIO_DEVICE() for EW-CG1102GC

Ondrej Zary (1):
      rt2500usb: fallback to SW encryption for TKIP+AES

Reinette Chatre (2):
      Merge branch 'wireless-2.6' into wireless-next-2.6
      iwlagn: reduce severity of disconnected antennas warning

Sebastian Smolorz (2):
      at76c50x-usb: Move function at76_join() several lines up
      at76c50x-usb: Extract bssid from authentication frame

Sujith (2):
      ath9k_htc: Update supported product list
      ath9k_htc: Add LED support for AR7010

Uwe Kleine-K=F6nig (2):
      cfg80211: move cfg80211_exit to .exit.text
      wireless: move regulatory_init to .init.text

Vasanthakumar Thiagarajan (4):
      ath9k: Fix bug in starting ani
      ath9k: Fix bug in paprd
      ath9k: Remove unused paprd_txok
      ath9k: Wakeup the chip in an appropriate place in ath_paprd_calib=
rate()

Vivek Natarajan (1):
      ath9k: Add a module parameter to disable led blinking.

Wey-Yi Guy (11):
      iwlwifi: move agn specific rx related code to iwl-agn-rx.c
      iwlwifi: move _agn statistics related structure
      iwlwifi: move calibration from iwlcore to iwlagn
      iwlwifi: code cleanup to remove un-necessary "goto"
      iwlwifi: remove non-exist reference
      iwlwifi: set TX_CMD_FLAG_PROT_REQUIRE_MSK in tx_flag
      iwlwifi: name change from signal protection flag
      iwlwifi: enable DC calibration based on config parameter
      iwlwifi: add a mechanism to disable plcp error checking
      iwlwifi: turn on RTS/CTS after aggregation become operational
      iwlwifi: add disable rf calibration support for 6000g2a and 6000g=
2b

 Documentation/networking/README.ipw2200            |    2 +-
 drivers/net/b44.c                                  |  144 +-
 drivers/net/wireless/at76c50x-usb.c                |  108 +-
 drivers/net/wireless/at76c50x-usb.h                |    1 +
 drivers/net/wireless/ath/ath5k/Makefile            |    1 +
 drivers/net/wireless/ath/ath5k/ani.c               |   20 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |   19 +-
 drivers/net/wireless/ath/ath5k/attach.c            |    2 -
 drivers/net/wireless/ath/ath5k/base.c              |  373 ++--
 drivers/net/wireless/ath/ath5k/caps.c              |    7 -
 drivers/net/wireless/ath/ath5k/debug.c             |   79 +-
 drivers/net/wireless/ath/ath5k/debug.h             |    9 +-
 drivers/net/wireless/ath/ath5k/desc.c              |  152 +-
 drivers/net/wireless/ath/ath5k/desc.h              |  310 ++--
 drivers/net/wireless/ath/ath5k/dma.c               |   13 -
 drivers/net/wireless/ath/ath5k/eeprom.c            |    3 +-
 drivers/net/wireless/ath/ath5k/gpio.c              |    7 -
 drivers/net/wireless/ath/ath5k/pcu.c               |   24 -
 drivers/net/wireless/ath/ath5k/phy.c               |   82 +-
 drivers/net/wireless/ath/ath5k/qcu.c               |    9 -
 drivers/net/wireless/ath/ath5k/reset.c             |   64 +-
 drivers/net/wireless/ath/ath5k/sysfs.c             |  116 +
 drivers/net/wireless/ath/ath9k/Makefile            |    3 +-
 drivers/net/wireless/ath/ath9k/ani.c               |  743 ++++++-
 drivers/net/wireless/ath/ath9k/ani.h               |   78 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |  372 +++-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |  118 +-
 drivers/net/wireless/ath/ath9k/ar9002_initvals.h   |    6 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.h        |    7 +
 .../{ar9003_initvals.h =3D> ar9003_2p0_initvals.h}   |  254 ++--
 .../{ar9003_initvals.h =3D> ar9003_2p2_initvals.h}   |  433 ++--
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   10 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   13 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |  185 ++-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |   13 +
 drivers/net/wireless/ath/ath9k/ar9003_mac.h        |    5 +
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |  714 ++++++
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |  513 ++++-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |  298 ++-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   89 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |    3 +-
 drivers/net/wireless/ath/ath9k/common.c            |  314 +---
 drivers/net/wireless/ath/ath9k/common.h            |   77 +-
 drivers/net/wireless/ath/ath9k/debug.c             |   68 +-
 drivers/net/wireless/ath/ath9k/debug.h             |    2 +
 drivers/net/wireless/ath/ath9k/eeprom.c            |   29 +
 drivers/net/wireless/ath/ath9k/eeprom.h            |    5 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |    1 +
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |  618 +++---
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |    1 +
 drivers/net/wireless/ath/ath9k/gpio.c              |    9 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c           |   71 +-
 drivers/net/wireless/ath/ath9k/hif_usb.h           |    2 +
 drivers/net/wireless/ath/ath9k/htc.h               |   38 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |   23 +
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |  163 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |  493 +++--
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |   86 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c           |    3 +-
 drivers/net/wireless/ath/ath9k/hw-ops.h            |   16 +
 drivers/net/wireless/ath/ath9k/hw.c                |  304 ++--
 drivers/net/wireless/ath/ath9k/hw.h                |  100 +-
 drivers/net/wireless/ath/ath9k/init.c              |   58 +-
 drivers/net/wireless/ath/ath9k/mac.c               |   14 +-
 drivers/net/wireless/ath/ath9k/mac.h               |   13 +-
 drivers/net/wireless/ath/ath9k/main.c              |  427 ++---
 drivers/net/wireless/ath/ath9k/pci.c               |    1 +
 drivers/net/wireless/ath/ath9k/rc.c                |  184 +-
 drivers/net/wireless/ath/ath9k/recv.c              |  296 +++-
 drivers/net/wireless/ath/ath9k/reg.h               |   90 +-
 drivers/net/wireless/ath/ath9k/virtual.c           |    2 +-
 drivers/net/wireless/ath/ath9k/wmi.c               |    3 -
 drivers/net/wireless/ath/ath9k/xmit.c              |  161 +-
 drivers/net/wireless/b43/dma.c                     |   69 +-
 drivers/net/wireless/b43/main.c                    |    2 +-
 drivers/net/wireless/b43/sdio.c                    |    1 +
 drivers/net/wireless/b43legacy/dma.c               |   49 +-
 drivers/net/wireless/hostap/hostap_ap.c            |    3 +-
 drivers/net/wireless/hostap/hostap_main.c          |    2 -
 drivers/net/wireless/ipw2x00/ipw2100.c             |   18 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |    7 +-
 drivers/net/wireless/iwlwifi/Kconfig               |    6 +-
 drivers/net/wireless/iwlwifi/Makefile              |    4 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    5 +
 drivers/net/wireless/iwlwifi/iwl-3945-debugfs.c    |   28 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c            |  208 +--
 drivers/net/wireless/iwlwifi/iwl-4965.c            |   96 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   67 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |  487 +++--
 .../iwlwifi/{iwl-calib.c =3D> iwl-agn-calib.c}       |   26 +-
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c     |   91 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c        |   32 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |  233 +--
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |   20 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c          |  284 +++
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |   82 +-
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c       |  123 +
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  392 +++-
 drivers/net/wireless/iwlwifi/iwl-agn.h             |   44 +
 drivers/net/wireless/iwlwifi/iwl-commands.h        |   35 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |  288 +--
 drivers/net/wireless/iwlwifi/iwl-core.h            |   35 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   92 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   95 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |    3 +
 drivers/net/wireless/iwlwifi/iwl-helpers.h         |   27 +
 drivers/net/wireless/iwlwifi/iwl-rx.c              |  242 +--
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   49 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c             |  164 +-
 drivers/net/wireless/iwlwifi/iwl-sta.h             |   32 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   33 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |  138 +-
 drivers/net/wireless/iwmc3200wifi/cfg80211.c       |   12 +-
 drivers/net/wireless/iwmc3200wifi/hal.c            |    2 +-
 drivers/net/wireless/iwmc3200wifi/rx.c             |    4 +-
 drivers/net/wireless/libertas/Makefile             |    3 -
 drivers/net/wireless/libertas/assoc.c              | 2264 ------------=
-------
 drivers/net/wireless/libertas/assoc.h              |  155 --
 drivers/net/wireless/libertas/cfg.c                | 2038 ++++++++++++=
+++++-
 drivers/net/wireless/libertas/cfg.h                |   21 +-
 drivers/net/wireless/libertas/cmd.c                |  124 +-
 drivers/net/wireless/libertas/cmdresp.c            |  111 +-
 drivers/net/wireless/libertas/debugfs.c            |   54 +-
 drivers/net/wireless/libertas/decl.h               |   10 +-
 drivers/net/wireless/libertas/dev.h                |   68 +-
 drivers/net/wireless/libertas/ethtool.c            |   29 +-
 drivers/net/wireless/libertas/host.h               |   28 +-
 drivers/net/wireless/libertas/if_sdio.c            |   58 +
 drivers/net/wireless/libertas/if_usb.c             |   12 +-
 drivers/net/wireless/libertas/main.c               |  305 +--
 drivers/net/wireless/libertas/mesh.c               |    6 +-
 drivers/net/wireless/libertas/mesh.h               |    5 -
 drivers/net/wireless/libertas/rx.c                 |  121 +-
 drivers/net/wireless/libertas/scan.c               | 1354 -----------
 drivers/net/wireless/libertas/scan.h               |   63 -
 drivers/net/wireless/libertas/tx.c                 |   12 +-
 drivers/net/wireless/libertas/wext.c               | 2353 ------------=
--------
 drivers/net/wireless/libertas/wext.h               |   17 -
 drivers/net/wireless/libertas_tf/if_usb.c          |    5 +-
 drivers/net/wireless/mac80211_hwsim.c              |    5 +
 drivers/net/wireless/mwl8k.c                       |   12 +-
 drivers/net/wireless/orinoco/hermes_dld.c          |    2 +-
 drivers/net/wireless/orinoco/orinoco_usb.c         |    4 +-
 drivers/net/wireless/orinoco/wext.c                |    4 +-
 drivers/net/wireless/p54/eeprom.c                  |    4 +-
 drivers/net/wireless/p54/p54spi.c                  |    5 +-
 drivers/net/wireless/p54/p54usb.c                  |    6 +-
 drivers/net/wireless/prism54/isl_ioctl.c           |   11 +-
 drivers/net/wireless/rndis_wlan.c                  |   56 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |   16 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |   16 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |   40 +-
 drivers/net/wireless/rt2x00/rt2800.h               |   57 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |  314 ++-
 drivers/net/wireless/rt2x00/rt2800lib.h            |   13 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |  151 +-
 drivers/net/wireless/rt2x00/rt2800pci.h            |   19 -
 drivers/net/wireless/rt2x00/rt2800usb.c            |  119 +-
 drivers/net/wireless/rt2x00/rt2800usb.h            |   37 -
 drivers/net/wireless/rt2x00/rt2x00.h               |   44 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |   12 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c          |    1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   43 +-
 drivers/net/wireless/rt2x00/rt2x00dump.h           |    7 +-
 drivers/net/wireless/rt2x00/rt2x00ht.c             |   47 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h            |   26 +-
 drivers/net/wireless/rt2x00/rt2x00link.c           |    8 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   10 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |   33 +-
 drivers/net/wireless/rt2x00/rt2x00pci.h            |   10 -
 drivers/net/wireless/rt2x00/rt2x00queue.c          |   86 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |    9 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |   68 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h            |   29 -
 drivers/net/wireless/rt2x00/rt61pci.c              |   62 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |   52 +-
 drivers/net/wireless/rtl818x/rtl8180_dev.c         |    2 +-
 drivers/net/wireless/wl12xx/Kconfig                |    4 +-
 drivers/net/wireless/wl12xx/wl1251_main.c          |    4 +-
 drivers/net/wireless/wl12xx/wl1251_sdio.c          |   40 +-
 drivers/net/wireless/wl12xx/wl1271.h               |   31 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.c           |   41 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.h           |   28 +-
 drivers/net/wireless/wl12xx/wl1271_event.c         |   10 +-
 drivers/net/wireless/wl12xx/wl1271_ini.h           |  123 +
 drivers/net/wireless/wl12xx/wl1271_main.c          |   95 +-
 drivers/net/wireless/wl12xx/wl1271_sdio.c          |    2 +-
 drivers/net/wireless/wl12xx/wl1271_testmode.c      |   11 +-
 drivers/net/wireless/wl12xx/wl1271_tx.c            |   36 +-
 drivers/net/wireless/wl12xx/wl1271_tx.h            |    1 +
 drivers/net/wireless/zd1211rw/zd_mac.c             |    5 +-
 drivers/net/wireless/zd1211rw/zd_mac.h             |    3 +-
 drivers/net/wireless/zd1211rw/zd_usb.c             |    2 +-
 drivers/ssb/driver_chipcommon.c                    |   25 +
 drivers/ssb/driver_chipcommon_pmu.c                |   17 +-
 drivers/ssb/main.c                                 |   76 +-
 drivers/ssb/pci.c                                  |   15 +-
 include/linux/eeprom_93cx6.h                       |    1 +
 include/linux/nl80211.h                            |   24 +-
 include/linux/ssb/ssb.h                            |  159 +--
 include/net/cfg80211.h                             |  137 +-
 include/net/mac80211.h                             |  120 +-
 net/mac80211/Kconfig                               |    8 +
 net/mac80211/Makefile                              |    4 +
 net/mac80211/agg-rx.c                              |  123 +-
 net/mac80211/agg-tx.c                              |  554 +++--
 net/mac80211/cfg.c                                 |  100 +-
 net/mac80211/debugfs.c                             |  154 +-
 net/mac80211/debugfs_key.c                         |    2 +-
 net/mac80211/debugfs_sta.c                         |   65 +-
 net/mac80211/driver-ops.h                          |  102 +-
 net/mac80211/driver-trace.h                        |  210 +-
 net/mac80211/ht.c                                  |   50 +-
 net/mac80211/ibss.c                                |  109 +-
 net/mac80211/ieee80211_i.h                         |   73 +-
 net/mac80211/iface.c                               |  188 ++-
 net/mac80211/key.c                                 |  290 +--
 net/mac80211/key.h                                 |   30 +-
 net/mac80211/main.c                                |  116 +-
 net/mac80211/mesh.c                                |   73 +-
 net/mac80211/mesh.h                                |    2 -
 net/mac80211/mesh_hwmp.c                           |    4 +-
 net/mac80211/mesh_pathtbl.c                        |    4 +-
 net/mac80211/mesh_plink.c                          |   42 +-
 net/mac80211/mlme.c                                |  239 +--
 net/mac80211/pm.c                                  |   18 +-
 net/mac80211/rate.h                                |   13 +
 net/mac80211/rc80211_minstrel_ht.c                 |  825 +++++++
 net/mac80211/rc80211_minstrel_ht.h                 |  130 ++
 net/mac80211/rc80211_minstrel_ht_debugfs.c         |  118 +
 net/mac80211/rx.c                                  |  193 +-
 net/mac80211/scan.c                                |    6 +-
 net/mac80211/sta_info.c                            |   22 +-
 net/mac80211/sta_info.h                            |  113 +-
 net/mac80211/status.c                              |    6 +-
 net/mac80211/tx.c                                  |   93 +-
 net/mac80211/util.c                                |   31 +-
 net/mac80211/work.c                                |    2 +-
 net/mac80211/wpa.c                                 |    8 +-
 net/wireless/chan.c                                |    5 +-
 net/wireless/core.c                                |    2 +-
 net/wireless/core.h                                |    1 +
 net/wireless/mlme.c                                |    8 +-
 net/wireless/nl80211.c                             |   89 +-
 net/wireless/reg.c                                 |    6 +-
 net/wireless/reg.h                                 |    2 +-
 net/wireless/wext-compat.c                         |   10 +-
 248 files changed, 14685 insertions(+), 13932 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath5k/sysfs.c
 copy drivers/net/wireless/ath/ath9k/{ar9003_initvals.h =3D> ar9003_2p0=
_initvals.h} (87%)
 rename drivers/net/wireless/ath/ath9k/{ar9003_initvals.h =3D> ar9003_2=
p2_initvals.h} (78%)
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9003_paprd.c
 rename drivers/net/wireless/iwlwifi/{iwl-calib.c =3D> iwl-agn-calib.c}=
 (98%)
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-rx.c
 delete mode 100644 drivers/net/wireless/libertas/assoc.c
 delete mode 100644 drivers/net/wireless/libertas/assoc.h
 delete mode 100644 drivers/net/wireless/libertas/scan.c
 delete mode 100644 drivers/net/wireless/libertas/scan.h
 delete mode 100644 drivers/net/wireless/libertas/wext.c
 delete mode 100644 drivers/net/wireless/libertas/wext.h
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_ini.h
 create mode 100644 net/mac80211/rc80211_minstrel_ht.c
 create mode 100644 net/mac80211/rc80211_minstrel_ht.h
 create mode 100644 net/mac80211/rc80211_minstrel_ht_debugfs.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2010-07-01.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
