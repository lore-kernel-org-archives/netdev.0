From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2010-11-29
Date: Mon, 29 Nov 2010 14:13:52 -0500
Message-ID: <20101129191352.GB8199@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Between celebrating my birthday and the Thanksgiving holiday, this pull
request is a bit bigger than usual...sorry!

=46or the most part, this is the usual stuff -- driver updates and the
like.  mwl8k, wl1271, ath9k, carl9170, rt2x00, b43, and iwlwifi all get
significant attention, along with a smattering of others.  mac80211 get=
s
a variety of updates as well.

This includes the movement of an EWMA library to lib for general use.
Also included is some file renaming for drivers/net/wireless/wl12xx.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit e9248fbd6b6f7ef1917bfffe998654e40dfb=
4cfd:

  vmxnet3: fix compilation when RSS is disabled (2010-11-28 18:25:33 -0=
800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Arik Nemtsov (2):
      mac80211: support hardware TX fragmentation offload
      wl1271: add support for HW TX fragmentation

Ben Greear (1):
      ath5k: Cleanup opmode setting logic.

Brian Cavagnolo (6):
      mwl8k: revert unnecessary modification of tx descriptor
      mwl8k: factor out firmware loading and hw init code
      mwl8k: choose proper firmware image as directed by user
      mwl8k: add API version checking for AP firmware
      mwl8k: make initial firmware load asynchronous
      mwl8k: use const struct fw pointers throughout

Bruno Randolf (7):
      cfg80211: Add nl80211 antenna configuration
      mac80211: Add antenna configuration
      ath5k: Add support for antenna configuration
      lib: Add generic exponentially weighted moving average (EWMA) fun=
ction
      ath5k: Use generic EWMA library
      nl80211/mac80211: Report signal average
      cfg80211: Add documentation for antenna ops

Christian Lamparter (2):
      carl9170: fix virtual interface setup crash
      carl9170: fix init-self regression

Daniel Drake (1):
      libertas: don't block usb8388 suspend if no wakeup conditions are=
 set

Daniel Klaffenbach (1):
      ssb: b43-pci-bridge: Add new vendor for BCM4318

Deepak Saxena (1):
      libertas: EHS_REMOVE_WAKEUP is not always supported

=46elix Fietkau (36):
      ath9k: remove the unnecessary private xretry tx flag
      ath9k: handle tx underrun in the driver instead of rate control
      ath9k: remove the tx info padding byte abuse
      ath9k: clean up tx buffer setup
      ath9k_hw: add a private op for configuring radar pulse detection
      cfg80211: add support for setting the ad-hoc multicast rate
      mac80211: add support for setting the ad-hoc multicast rate
      ath9k_hw: set default values for radar pulse detection
      ath9k: fix PA predistortion training frame setup
      ath9k: remove bfs_seqno from struct ath_buf_state
      ath9k: remove bfs_tidno from struct ath_buf_state
      ath9k: remove bfs_keytype from struct ath_buf_state
      ath9k: remove bfs_paprd_timestamp from struct ath_buf_state
      ath9k: remove bfs_keyix from struct ath_buf_state
      ath9k: remove bfs_al from struct ath_buf_state
      ath9k: remove bfs_nframes from struct ath_buf_state
      ath9k: remove bfs_frmlen from struct ath_buf_state
      ath9k: remove bf_tx_aborted from struct ath_buf
      ath9k: clean up code duplication around ath_tx_start
      ath9k: block new AMPDU sessions if SC_OP_TXAGGR is not set
      ath9k: more tx setup cleanups
      ath9k: store frame information used by aggregation inside the skb=
 tx info
      ath9k_hw: add support for reading EEPROM data from the internal O=
TP ROM
      ath9k: add support for reading eeprom from platform data on PCI d=
evices
      ath9k_hw: support reading calibration data from flash on AR9003
      ath9k: fix timeout on stopping rx dma
      ath9k: fix recursive locking in the tx flush path
      ath9k_hw: fix A-MPDU key search issues on AR9003
      ath9k_htc: fix eeprom access
      mac80211: restart beacon miss timer on system resume from suspend
      mac80211: calculate beacon loss time accurately
      mac80211: probe the AP when resuming
      cfg80211/mac80211: improve ad-hoc multicast rate handling
      mac80211: use nullfunc instead of probe request for connection mo=
nitoring
      mac80211: reduce the number of retries for nullfunc probing
      ath9k_hw: remove ath9k_hw_stoppcurecv

Gertjan van Wingerde (5):
      rt2x00: Add initial support for RT3370/RT3390 devices.
      rt2x00: Clean up Kconfig for RT2800 devices.
      rt2x00: Remove RT30XX Kconfig variables.
      rt2x00: Remove unneccessary internal Kconfig symbols.
      rt2x00: Use ioremap for SoC devices instead of KSEG1ADDR.

Gery Kahn (1):
      wl1271: cleanup unused code of calibration structures

Guennadi Liakhovetski (1):
      wireless: b43: fix error path in SDIO

Helmut Schaa (1):
      mac80211: Disable hw crypto for GTKs on AP VLAN interfaces

Huang Weiyi (1):
      libertas: remove duplicated #include

Ivo van Doorn (1):
      rt2x00: Increase REGISTER_BUSY_COUNT

Joe Perches (16):
      drivers/net/wireless/ath/debug.c: Use printf extension %pV
      drivers/net/wireless/b43/main.c: Use printf extension %pV
      drivers/net/wireless/b43legacy/main.c: Use printf extension %pV
      ar9170: Use const
      ath5k: Use static const
      ath9k: Use static const
      carl9170: Use static const
      atmel: Use static const
      b43: Use static const
      iwlwifi: Use static const
      libertas: Use static const
      ray_cs: Use static const
      rndis_wlan: Use static const
      rt2x00: Use static const
      zd1211rw: Use const
      net/wireless: Use pr_<level> and netdev_<level>

Johannes Berg (14):
      iwlagn: fix some naming regarding FIFOs
      iwlagn: remove unused variable swq_id
      iwlagn: remove a bogus AGG_OFF check
      iwlwifi: pass txq to wake/stop queue
      iwlwifi: always build swq_id as virtual queue ID
      iwlagn: fix PAN queues
      iwlagn: avoid crash if vif is not assigned
      iwlagn: reprogram AP STA after assoc
      iwlagn: fix PAN slot timing wrt. DTIM
      mac80211: defines for AC numbers
      mac80211: fix powersaving clients races
      iwlwifi: fix modular 3945 only build
      cfg80211: allow using CQM event to notify packet loss
      mac80211: implement packet loss notification

John W. Linville (6):
      iwmc3200wifi: clarify potentially undefined operation in iwm_scan=
_ssids
      rndis_wlan: avoid uninitialized var warning in rndis_wlan_craft_c=
onnected_bss
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      Revert "nl80211/mac80211: Report signal average"
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Jussi Kivilinna (2):
      rndis_wlan: workaround device not returning bss for currently con=
nected AP
      rndis_wlan: workaround poor scanning with BCM4320a

Juuso Oikarinen (4):
      mac80211: Add function to get probe request template for current =
AP
      wl1271: Prevent ad-hoc and active scanning on 11a DFS frequencies
      Revert "wl1271: Change supported channel order for a more optimal=
 scan"
      wl12xx: Unset bssid filter, ssid and bssid from firmware on disas=
soc

Luis R. Rodriguez (6):
      cfg80211: put core regulatory request into queue
      cfg80211: move reg_work and reg_todo above
      cfg80211: move mutex locking to reg_process_pending_hints()
      cfg80211: Fix regulatory bug with multiple cards and delays
      ath9k: avoid aggregation for VO traffic
      mac80211: avoid aggregation for VO traffic

Mohammed Shafi Shajakhan (1):
      ath9k_htc: Use macro for caldata array size

Nishant Sarmukadam (1):
      mwl8k: rf_tx_power cmd not supported by AP firmware APIv1

RA-Jay Hung (3):
      rt2x00: Fix rt2800 USB TX Path DMA issue
      rt2x00: Fix header_length in rt2x00lib_txdone
      rt2x00: Modify rt2x00queue_remove_l2pad to make skb->data two-byt=
e alignment

Rafa=C5=82 Mi=C5=82ecki (12):
      ssb: workarounds: be verbose about hacking SPROM revision, don't =
duplicate code
      ssb: return -ENOMEM on alloc fail (instead of CRC check's result)
      ssb: drop BCM4328 hack for SPROM revision
      b43: N-PHY: add 2056 radio channels tables
      b43: rfkill: use HI enabled bit for all devices
      b43: N-PHY: fix values for PHY regs in channel tables of 2055 rad=
io
      b43: N-PHY: minor fixes to match specs
      b43: N-PHY: fix some typos, conditions, set gain_boost
      b43: N-PHY: init BPHY when needed
      b43: N-PHY: fix BPHY init
      b43: N-PHY: rev2: save and restore PHY regs on RSSI poll
      b43: N-PHY: little cleanups

Rajkumar Manoharan (4):
      ath: Add a driver_info bitmask field
      ath9k_htc: Add driver_info in usb device list
      ath9k_hw: Fix eeprom offset for AR9287 devices (PCI/USB)
      ath9k_htc: Identify devices using driver_info

Senthil Balasubramanian (6):
      ath9k_hw: Fix a reset failure on AR9382 (2x2).
      ath9k_hw: Add new member into the eeprom structure.
      ath9k_hw: Initialize 2GHz CTL properly.
      ath9k_hw: Fix paprd training frame failure.
      ath9k_hw: add eeprom templates for ar9003 family chipsets
      ath9k_hw: Fix low throughput issue with AR93xx

Shahar Levi (1):
      wl1271: Change wl12xx Files Names

Shanyu Zhao (2):
      iwlagn: update QoS before commit associated RXON
      iwlagn: check change before commit RXON cmd

Stanislaw Gruszka (3):
      iwl3945: remove unused len_org variable
      iwlagn: simplify iwlagn_tx_skb
      iwlwifi: kill elapsed_jiffies

Vasanthakumar Thiagarajan (5):
      ath9k_hw: Fix XPABIAS level configuration for AR9003
      ath9k_hw: Enable strong signal detection for AR9003
      ath9k_hw: Improve power control accuracy for AR9003
      ath9k_hw: Add helper function for interpolation
      ath9k: Fix bug in delimiter padding computation

Wey-Yi Guy (12):
      iwlagn: used frame count info in compressed ba packet
      iwlagn: set dynamic aggregation threshold for BT
      iwlagn: support dynamic aggregation for BT coex
      iwlagn: change default ACK/CTS MASK setting for WiFi/BT coex
      iwlwifi: change default led mode for different devices
      iwlagn: use SKU information in the EEPROM
      iwlwifi: set STATUS_READY before commit_rxon
      iwlagn: name change for BT config flag
      iwlwifi: add more power management flags
      iwlwifi: consider BT for power management
      iwlwifi: power management checking for shadow register
      iwlwifi: advance power management support

 drivers/net/wireless/ath/ar9170/cmd.c              |    2 +-
 drivers/net/wireless/ath/ath.h                     |    6 +
 drivers/net/wireless/ath/ath5k/Kconfig             |    1 +
 drivers/net/wireless/ath/ath5k/ani.c               |   38 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |   26 +-
 drivers/net/wireless/ath/ath5k/base.c              |   50 +-
 drivers/net/wireless/ath/ath5k/debug.c             |    2 +-
 drivers/net/wireless/ath/ath9k/ani.c               |    8 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |   79 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.c        |   12 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   27 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     | 2758 +++++++++-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |   27 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |   28 +-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   51 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   42 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |   19 +
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |   12 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |   20 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |   17 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c           |   61 +-
 drivers/net/wireless/ath/ath9k/htc.h               |    4 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   38 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c           |    5 +-
 drivers/net/wireless/ath/ath9k/htc_hst.h           |    3 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   20 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   41 +
 drivers/net/wireless/ath/ath9k/init.c              |    3 +
 drivers/net/wireless/ath/ath9k/mac.c               |    8 -
 drivers/net/wireless/ath/ath9k/mac.h               |    1 -
 drivers/net/wireless/ath/ath9k/main.c              |   30 +-
 drivers/net/wireless/ath/ath9k/pci.c               |   42 +-
 drivers/net/wireless/ath/ath9k/rc.c                |   29 +-
 drivers/net/wireless/ath/ath9k/rc.h                |    6 -
 drivers/net/wireless/ath/ath9k/recv.c              |    2 +-
 drivers/net/wireless/ath/ath9k/reg.h               |   14 +-
 drivers/net/wireless/ath/ath9k/virtual.c           |    5 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |  631 +--
 drivers/net/wireless/ath/carl9170/cmd.c            |    2 +-
 drivers/net/wireless/ath/carl9170/main.c           |    2 +-
 drivers/net/wireless/ath/carl9170/tx.c             |    2 +-
 drivers/net/wireless/ath/debug.c                   |    9 +-
 drivers/net/wireless/atmel.c                       |    6 +-
 drivers/net/wireless/b43/main.c                    |   48 +-
 drivers/net/wireless/b43/phy_common.c              |    8 +-
 drivers/net/wireless/b43/phy_n.c                   |   86 +-
 drivers/net/wireless/b43/radio_2055.c              |  248 +-
 drivers/net/wireless/b43/radio_2056.c              | 5968 ++++++++++++=
++++++++
 drivers/net/wireless/b43/rfkill.c                  |   19 +-
 drivers/net/wireless/b43/sdio.c                    |    1 +
 drivers/net/wireless/b43legacy/main.c              |   47 +-
 drivers/net/wireless/iwlwifi/Makefile              |    4 +
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    8 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c            |    6 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c            |   13 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   14 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   46 +-
 drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c      |   21 +
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c        |    5 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |   27 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |   32 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |  103 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |  110 +-
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c       |   65 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |   11 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |   25 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   11 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |    9 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |    3 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |   12 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h         |   45 +-
 drivers/net/wireless/iwlwifi/iwl-led.c             |   10 +-
 drivers/net/wireless/iwlwifi/iwl-led.h             |    6 +-
 drivers/net/wireless/iwlwifi/iwl-power.c           |   95 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |    3 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c             |   51 +-
 drivers/net/wireless/iwlwifi/iwl-sta.h             |    1 +
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   11 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |   11 +-
 drivers/net/wireless/iwmc3200wifi/commands.c       |    2 +-
 drivers/net/wireless/libertas/cfg.c                |    4 +-
 drivers/net/wireless/libertas/cmd.c                |    8 +
 drivers/net/wireless/libertas/dev.h                |    1 +
 drivers/net/wireless/libertas/if_usb.c             |   13 +-
 drivers/net/wireless/libertas/main.c               |    3 +-
 drivers/net/wireless/libertas/rx.c                 |    4 +-
 drivers/net/wireless/mwl8k.c                       |  677 ++-
 drivers/net/wireless/ray_cs.c                      |    4 +-
 drivers/net/wireless/rndis_wlan.c                  |  206 +-
 drivers/net/wireless/rt2x00/Kconfig                |   72 +-
 drivers/net/wireless/rt2x00/rt2800.h               |    1 +
 drivers/net/wireless/rt2x00/rt2800lib.c            |   11 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |   49 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |  212 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |    2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |    8 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |    6 +-
 drivers/net/wireless/rt2x00/rt2x00soc.c            |    6 +-
 drivers/net/wireless/wl12xx/Kconfig                |   52 +-
 drivers/net/wireless/wl12xx/Makefile               |   17 +-
 .../net/wireless/wl12xx/{wl1271_acx.c =3D> acx.c}    |   12 +-
 .../net/wireless/wl12xx/{wl1271_acx.h =3D> acx.h}    |   10 +-
 .../net/wireless/wl12xx/{wl1271_boot.c =3D> boot.c}  |   10 +-
 .../net/wireless/wl12xx/{wl1271_boot.h =3D> boot.h}  |    2 +-
 .../net/wireless/wl12xx/{wl1271_cmd.c =3D> cmd.c}    |   12 +-
 .../net/wireless/wl12xx/{wl1271_cmd.h =3D> cmd.h}    |   54 +-
 .../net/wireless/wl12xx/{wl1271_conf.h =3D> conf.h}  |    4 +-
 .../wl12xx/{wl1271_debugfs.c =3D> debugfs.c}         |   10 +-
 .../wl12xx/{wl1271_debugfs.h =3D> debugfs.h}         |    6 +-
 .../wireless/wl12xx/{wl1271_event.c =3D> event.c}    |   12 +-
 .../wireless/wl12xx/{wl1271_event.h =3D> event.h}    |    4 +-
 .../net/wireless/wl12xx/{wl1271_ini.h =3D> ini.h}    |    4 +-
 .../net/wireless/wl12xx/{wl1271_init.c =3D> init.c}  |   10 +-
 .../net/wireless/wl12xx/{wl1271_init.h =3D> init.h}  |    6 +-
 drivers/net/wireless/wl12xx/{wl1271_io.c =3D> io.c}  |    4 +-
 drivers/net/wireless/wl12xx/{wl1271_io.h =3D> io.h}  |    6 +-
 .../net/wireless/wl12xx/{wl1271_main.c =3D> main.c}  |  183 +-
 drivers/net/wireless/wl12xx/{wl1271_ps.c =3D> ps.c}  |    6 +-
 drivers/net/wireless/wl12xx/{wl1271_ps.h =3D> ps.h}  |    8 +-
 .../net/wireless/wl12xx/{wl1271_reg.h =3D> reg.h}    |    0
 drivers/net/wireless/wl12xx/{wl1271_rx.c =3D> rx.c}  |   12 +-
 drivers/net/wireless/wl12xx/{wl1271_rx.h =3D> rx.h}  |    4 +-
 .../net/wireless/wl12xx/{wl1271_scan.c =3D> scan.c}  |    8 +-
 .../net/wireless/wl12xx/{wl1271_scan.h =3D> scan.h}  |    6 +-
 .../net/wireless/wl12xx/{wl1271_sdio.c =3D> sdio.c}  |    4 +-
 .../net/wireless/wl12xx/{wl1271_spi.c =3D> spi.c}    |    6 +-
 .../wl12xx/{wl1271_testmode.c =3D> testmode.c}       |    6 +-
 .../wl12xx/{wl1271_testmode.h =3D> testmode.h}       |    4 +-
 drivers/net/wireless/wl12xx/{wl1271_tx.c =3D> tx.c}  |   12 +-
 drivers/net/wireless/wl12xx/{wl1271_tx.h =3D> tx.h}  |    4 +-
 drivers/net/wireless/wl12xx/{wl1271.h =3D> wl12xx.h} |    8 +-
 drivers/net/wireless/zd1211rw/zd_chip.c            |    4 +-
 drivers/ssb/b43_pci_bridge.c                       |    1 +
 drivers/ssb/pci.c                                  |   52 +-
 include/linux/average.h                            |   32 +
 include/linux/nl80211.h                            |   32 +
 include/linux/pci_ids.h                            |    1 +
 include/net/cfg80211.h                             |   17 +
 include/net/mac80211.h                             |   50 +-
 include/net/regulatory.h                           |    7 +
 lib/Kconfig                                        |    3 +
 lib/Makefile                                       |    2 +
 lib/average.c                                      |   57 +
 net/mac80211/cfg.c                                 |   26 +
 net/mac80211/driver-ops.h                          |   37 +
 net/mac80211/driver-trace.h                        |   71 +
 net/mac80211/ibss.c                                |    2 +
 net/mac80211/ieee80211_i.h                         |   10 +
 net/mac80211/key.c                                 |    9 +-
 net/mac80211/mlme.c                                |  143 +-
 net/mac80211/rate.c                                |   18 +-
 net/mac80211/rc80211_minstrel_ht.c                 |    3 +
 net/mac80211/rx.c                                  |    2 -
 net/mac80211/sta_info.c                            |   17 +-
 net/mac80211/sta_info.h                            |    3 +
 net/mac80211/status.c                              |   26 +
 net/mac80211/tx.c                                  |   16 +-
 net/mac80211/util.c                                |   40 +-
 net/mac80211/wme.c                                 |   11 +-
 net/wireless/core.c                                |    8 +-
 net/wireless/lib80211.c                            |    8 +-
 net/wireless/lib80211_crypt_tkip.c                 |   16 +-
 net/wireless/mlme.c                                |   12 +
 net/wireless/nl80211.c                             |  111 +-
 net/wireless/nl80211.h                             |    4 +
 net/wireless/reg.c                                 |  127 +-
 net/wireless/util.c                                |   11 +-
 net/wireless/wext-core.c                           |   10 +-
 170 files changed, 12136 insertions(+), 2036 deletions(-)
 rename drivers/net/wireless/wl12xx/{wl1271_acx.c =3D> acx.c} (99%)
 rename drivers/net/wireless/wl12xx/{wl1271_acx.h =3D> acx.h} (99%)
 rename drivers/net/wireless/wl12xx/{wl1271_boot.c =3D> boot.c} (99%)
 rename drivers/net/wireless/wl12xx/{wl1271_boot.h =3D> boot.h} (98%)
 rename drivers/net/wireless/wl12xx/{wl1271_cmd.c =3D> cmd.c} (99%)
 rename drivers/net/wireless/wl12xx/{wl1271_cmd.h =3D> cmd.h} (91%)
 rename drivers/net/wireless/wl12xx/{wl1271_conf.h =3D> conf.h} (99%)
 rename drivers/net/wireless/wl12xx/{wl1271_debugfs.c =3D> debugfs.c} (=
99%)
 rename drivers/net/wireless/wl12xx/{wl1271_debugfs.h =3D> debugfs.h} (=
93%)
 rename drivers/net/wireless/wl12xx/{wl1271_event.c =3D> event.c} (98%)
 rename drivers/net/wireless/wl12xx/{wl1271_event.h =3D> event.h} (98%)
 rename drivers/net/wireless/wl12xx/{wl1271_ini.h =3D> ini.h} (98%)
 rename drivers/net/wireless/wl12xx/{wl1271_init.c =3D> init.c} (98%)
 rename drivers/net/wireless/wl12xx/{wl1271_init.h =3D> init.h} (93%)
 rename drivers/net/wireless/wl12xx/{wl1271_io.c =3D> io.c} (99%)
 rename drivers/net/wireless/wl12xx/{wl1271_io.h =3D> io.h} (98%)
 rename drivers/net/wireless/wl12xx/{wl1271_main.c =3D> main.c} (97%)
 rename drivers/net/wireless/wl12xx/{wl1271_ps.c =3D> ps.c} (98%)
 rename drivers/net/wireless/wl12xx/{wl1271_ps.h =3D> ps.h} (92%)
 rename drivers/net/wireless/wl12xx/{wl1271_reg.h =3D> reg.h} (100%)
 rename drivers/net/wireless/wl12xx/{wl1271_rx.c =3D> rx.c} (97%)
 rename drivers/net/wireless/wl12xx/{wl1271_rx.h =3D> rx.h} (98%)
 rename drivers/net/wireless/wl12xx/{wl1271_scan.c =3D> scan.c} (98%)
 rename drivers/net/wireless/wl12xx/{wl1271_scan.h =3D> scan.h} (97%)
 rename drivers/net/wireless/wl12xx/{wl1271_sdio.c =3D> sdio.c} (99%)
 rename drivers/net/wireless/wl12xx/{wl1271_spi.c =3D> spi.c} (99%)
 rename drivers/net/wireless/wl12xx/{wl1271_testmode.c =3D> testmode.c}=
 (98%)
 rename drivers/net/wireless/wl12xx/{wl1271_testmode.h =3D> testmode.h}=
 (93%)
 rename drivers/net/wireless/wl12xx/{wl1271_tx.c =3D> tx.c} (98%)
 rename drivers/net/wireless/wl12xx/{wl1271_tx.h =3D> tx.h} (99%)
 rename drivers/net/wireless/wl12xx/{wl1271.h =3D> wl12xx.h} (99%)
 create mode 100644 include/linux/average.h
 create mode 100644 lib/average.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2010-11-29.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
