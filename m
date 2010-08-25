From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2010-08-25
Date: Wed, 25 Aug 2010 16:36:12 -0400
Message-ID: <20100825203611.GM2557@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45885 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753255Ab0HYUol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 16:44:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is the usual huge first pull request for the 2.6.37 series...

Included are the usual batches of driver updates, including ath5k,
ath9k, b43, iwlwifi, libertas, rt2x00, wl1251, etc.  There is also a
flurry of mac80211 updates.  Also of note are some docbook enhancements
from Johannes.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 4562487a00445eab96311365ba15c41dc4d0=
43cd:

  mlx4_en: Fix build warning in mlx4_en_create_rx_ring. (2010-08-24 15:=
06:27 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Andrea Gelmini (1):
      net: mac80211: Fix a typo.

Andrew Morton (1):
      drivers/net/wireless/libertas/cfg.c: needs sched.h

Ben Hutchings (1):
      mac80211: Don't squash error codes in key setup functions

Bob Copeland (4):
      ath5k: clean up some comments
      ath5k: remove monitor check in receive_frame_ok filter
      ath5k: remove all mention of monitor iftype
      ath5k: don't enable probe request rx for STAs

Christian Lamparter (5):
      mac80211: put rx handlers into separate functions
      mac80211: remove unused rate function parameter
      mac80211: AMPDU rx reorder timeout timer
      p54spi: fix eeprom checksum
      p54: improve eeprom parser

Dan Williams (7):
      libertas: better scan response debugging
      libertas: better association request debugging
      libertas: [usb] use new firmware locations
      libertas: add two-stage firmware request helper
      libertas: [cs] use common firmware request helper and new firmwar=
e locations
      libertas: [sdio] use common firmware request helper and new firmw=
are locations
      libertas: [spi] use common firmware request helper and new firmwa=
re locations

=46elix Fietkau (5):
      mac80211: fix driver offchannel notification when the channel doe=
s not change
      ath9k: add a separate debug level for stuck beacons
      ath9k_hw: apply the noise floor validation to the median instead =
of single
      ath9k: use AP beacon miss as a trigger for fast recalibration
      ath9k: shorten the calibration interval during strong interferenc=
e

Grazvydas Ignotas (4):
      wl1251: add missing __packed modifier for some structs
      wl1251: fix event handling mechanism
      wl1251: fix beacon filter table structure
      wl1251: wait for join command complete event

G=E1bor Stefanik (4):
      b43: N-PHY: Implement Host Flags write during device init
      b43: N-PHY: Fix typo in function name (gain_crtl -> gain_ctrl)
      b43: N-PHY: Implement MAC PHY clock set
      b43: N-PHY: Implement RX core state setting for rev.2 and earlier=
 PHYs

Helmut Schaa (1):
      rt2x00: Update comments regarding TXWI and TX_STA_FIFO

Ivo van Doorn (6):
      rt2x00: Move USB tx/rx done handling to workqueue
      rt2x00: Set MIMO PS flag in tx descriptor for STAs in dynamic SMP=
S mode
      rt2x00: Add helper function for reporting tx status
      rt2x00: Request TXWI pointer from driver
      rt2x00: Implement TX status reporting for rt2800usb
      rt2x00: Remove ieee80211_rx_status from rt2x00_dev

Jay Sternberg (2):
      iwlwifi: enable experimental ucode support
      iwlwifi: move debug options into submenu

Johannes Berg (23):
      mac80211: don't check rates on PLCP error frames
      mac80211: unify scan and work mutexes
      iwlwifi: track IBSS manager status
      cfg80211: deauth doesn't always imply disconnect
      mac80211: per interface idle notification
      mac80211: allow drivers to request SM PS mode change
      cfg80211: support sysfs namespaces
      mac80211: use cipher suite selectors
      mac80211: move key tfm setup
      mac80211: remove unused status flag checks
      mac80211: dont advertise WEP if unavailable
      cfg80211: check if WEP is available for shared key auth
      cfg80211: mark ieee80211_hdrlen const
      mac80211: remove unused don't-encrypt flag
      cfg80211/mac80211: extensible frame processing
      wireless: move documentation books
      mac80211-hwsim: allow configuring IBSS
      iwlwifi: refactor iwl_setup_rxon_timing
      mac80211: fix docbook
      nl80211: some documentation fixes
      iwlagn: do not check for AP mode for WEP keys
      iwlwifi: do not spuriously call ieee80211_scan_completed
      cfg80211: add some documentation

John W. Linville (18):
      b43: update hw/fw version info in wiphy struct
      b43legacy: update hw/fw version info in wiphy struct
      p54: update fw version info in wiphy struct
      rt2x00: update fw version info in wiphy struct
      zd1211rw: update fw version info in wiphy struct
      mac80211: support use of NAPI for bottom-half processing
      rtl8180: use NAPI for bottom-half processing
      rtl8180: use RTL818X_MSR_ADHOC for IBSS connection
      rtl8187: consolidate MSR writes in rtl8187_bss_info_changed
      wireless: upcase alpha2 values in queue_regulatory_request
      iwlwifi: disable aspm by default
      ipw2100: avoid warning from pointer cast in call to IPW_DEBUG_TX
      iwm3200wifi: remove comparison to WIFI_IF_NTFY_MAX in iwm_ntf_wif=
i_if_wrapper
      b43: move hwrng registration driver to wireless core initializati=
on
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      rt2x00: do not shortcut rt2x00lib_config_antenna
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Julia Lawall (5):
      drivers/net/wireless/libertas: Adjust confusing if indentation
      drivers/net/wireless/prism54: Adjust confusing if indentation
      drivers/net/wireless/ath/ath9k: Adjust confusing if indentation
      drivers/net/wireless/wl12xx: Use available error codes
      drivers/net/wireless/wl12xx: Use available error codes

Julian Calaby (1):
      Hostap: Fix "'ret' set but not used" warning message from GCC in =
hostap

Luis R. Rodriguez (2):
      ath9k: add fastcc to debug print for channel change
      ath9k: remove duplicate get_hw_crypto_keytype()

Nick Kossifidis (2):
      ath5k: rename ath5k_hw_set_associd to _set_bssid
      ath5k: remove own (wrong) IEEE80211_MAX_LEN

Shanyu Zhao (3):
      iwlwifi: do not call ieee80211_frequency_to_channel
      iwlwifi: avoid race condition in channel change
      iwlwifi: cleanup iwl_set_rxon_channel()

Stanislaw Gruszka (1):
      iwlwifi: make scan workqueue functions static

Thomas Klute (2):
      libertas_tf: if_usb.c: Whitespace cleanup
      libertas_tf: if_usb.c: Some more formatting fixes

Vivek Natarajan (2):
      ath9k_common: Move bt_stomp to common for sharing with ath9k_htc.
      ath9k_htc: Add support for bluetooth coexistence.

Wey-Yi Guy (15):
      iwlwifi: make iwl_hw_detect static to _agn
      iwlagn: log pci revision id
      iwlwifi: make iwl_set_hw_params static to _agn
      iwlwifi: separate thermal throttling function
      iwlwifi: fix thermal throttling related power management operatio=
n
      iwlwifi: remove unused define
      iwlwifi: additional comments in iwl_cfg
      iwlwifi: max/min aggregation time limit
      iwlwifi: make aggregation time limit configurable
      iwlagn: adjust starting action for rate scale
      iwlagn: continue perform rate scale when error detected
      iwlwifi: additional parameter in REPLY_RX_PHY_CMD
      iwlwifi: more generic name for rssi calc in iwlagn
      iwlwifi: configurable ampdu factor and density
      iwlwifi: remove unused iwl_send_card_state function

 Documentation/DocBook/80211.tmpl              |  496 +++++++++++++++++=
+
 Documentation/DocBook/Makefile                |    2 +-
 Documentation/DocBook/mac80211.tmpl           |  337 ------------
 drivers/net/wireless/at76c50x-usb.c           |    7 +-
 drivers/net/wireless/ath/ar9170/main.c        |   31 +-
 drivers/net/wireless/ath/ath5k/ani.c          |    6 +-
 drivers/net/wireless/ath/ath5k/ath5k.h        |    7 +-
 drivers/net/wireless/ath/ath5k/attach.c       |    8 +-
 drivers/net/wireless/ath/ath5k/base.c         |   90 ++--
 drivers/net/wireless/ath/ath5k/dma.c          |    4 +-
 drivers/net/wireless/ath/ath5k/eeprom.c       |    4 +-
 drivers/net/wireless/ath/ath5k/pcu.c          |   32 +-
 drivers/net/wireless/ath/ath5k/phy.c          |   15 +-
 drivers/net/wireless/ath/ath5k/reg.h          |    2 +-
 drivers/net/wireless/ath/ath5k/reset.c        |   24 +-
 drivers/net/wireless/ath/ath5k/rfbuffer.h     |    4 +-
 drivers/net/wireless/ath/ath9k/Makefile       |    3 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c   |    2 +-
 drivers/net/wireless/ath/ath9k/ath9k.h        |    9 +-
 drivers/net/wireless/ath/ath9k/beacon.c       |    7 +-
 drivers/net/wireless/ath/ath9k/btcoex.c       |    7 +
 drivers/net/wireless/ath/ath9k/calib.c        |  109 ++++-
 drivers/net/wireless/ath/ath9k/calib.h        |    1 +
 drivers/net/wireless/ath/ath9k/common.c       |   67 ++-
 drivers/net/wireless/ath/ath9k/common.h       |   10 +
 drivers/net/wireless/ath/ath9k/gpio.c         |   40 +--
 drivers/net/wireless/ath/ath9k/hif_usb.c      |    3 +-
 drivers/net/wireless/ath/ath9k/htc.h          |   42 ++-
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c |  134 +++++
 drivers/net/wireless/ath/ath9k/htc_drv_init.c |   42 ++-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c |   17 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c      |    4 +-
 drivers/net/wireless/ath/ath9k/htc_hst.h      |    2 +-
 drivers/net/wireless/ath/ath9k/hw.h           |    1 +
 drivers/net/wireless/ath/ath9k/main.c         |   19 +-
 drivers/net/wireless/ath/ath9k/wmi.c          |    2 +
 drivers/net/wireless/ath/ath9k/wmi.h          |    1 +
 drivers/net/wireless/ath/ath9k/xmit.c         |   18 +-
 drivers/net/wireless/ath/debug.h              |    2 +
 drivers/net/wireless/b43/main.c               |   30 +-
 drivers/net/wireless/b43/phy_n.c              |   60 ++-
 drivers/net/wireless/b43legacy/main.c         |    5 +
 drivers/net/wireless/hostap/hostap_ioctl.c    |    2 +-
 drivers/net/wireless/ipw2x00/ipw2100.c        |    4 +-
 drivers/net/wireless/iwlwifi/Kconfig          |   10 +
 drivers/net/wireless/iwlwifi/Makefile         |    1 +
 drivers/net/wireless/iwlwifi/iwl-1000.c       |    5 +
 drivers/net/wireless/iwlwifi/iwl-4965.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c       |   12 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c       |    7 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c   |   21 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c     |   42 ++-
 drivers/net/wireless/iwlwifi/iwl-agn-tt.c     |  696 +++++++++++++++++=
++++++++
 drivers/net/wireless/iwlwifi/iwl-agn-tt.h     |  129 +++++
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c     |   16 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c        |  141 ++++-
 drivers/net/wireless/iwlwifi/iwl-commands.h   |   50 ++-
 drivers/net/wireless/iwlwifi/iwl-core.c       |  154 ++-----
 drivers/net/wireless/iwlwifi/iwl-core.h       |   29 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c    |    6 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h        |   20 +-
 drivers/net/wireless/iwlwifi/iwl-power.c      |  638 +----------------=
------
 drivers/net/wireless/iwlwifi/iwl-power.h      |   93 ----
 drivers/net/wireless/iwlwifi/iwl-scan.c       |   18 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c        |   24 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c         |    9 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c   |   69 ++--
 drivers/net/wireless/iwmc3200wifi/rx.c        |    7 +-
 drivers/net/wireless/libertas/cfg.c           |   62 ++-
 drivers/net/wireless/libertas/decl.h          |   13 +
 drivers/net/wireless/libertas/if_cs.c         |  130 +++--
 drivers/net/wireless/libertas/if_sdio.c       |  161 +++----
 drivers/net/wireless/libertas/if_sdio.h       |    4 -
 drivers/net/wireless/libertas/if_spi.c        |  150 +++---
 drivers/net/wireless/libertas/if_spi.h        |    5 -
 drivers/net/wireless/libertas/if_usb.c        |   60 ++-
 drivers/net/wireless/libertas/if_usb.h        |    1 +
 drivers/net/wireless/libertas/main.c          |  105 ++++
 drivers/net/wireless/libertas_tf/if_usb.c     |   57 ++-
 drivers/net/wireless/mac80211_hwsim.c         |    7 +-
 drivers/net/wireless/p54/Kconfig              |    1 +
 drivers/net/wireless/p54/eeprom.c             |   21 +-
 drivers/net/wireless/p54/fwio.c               |    6 +-
 drivers/net/wireless/p54/main.c               |    9 +-
 drivers/net/wireless/p54/p54spi_eeprom.h      |    2 +-
 drivers/net/wireless/p54/txrx.c               |   17 +-
 drivers/net/wireless/prism54/isl_ioctl.c      |    2 +-
 drivers/net/wireless/rt2x00/rt2500usb.c       |    4 +-
 drivers/net/wireless/rt2x00/rt2800.h          |   27 +-
 drivers/net/wireless/rt2x00/rt2800lib.c       |  130 +++++-
 drivers/net/wireless/rt2x00/rt2800lib.h       |   15 +-
 drivers/net/wireless/rt2x00/rt2800pci.c       |  119 +----
 drivers/net/wireless/rt2x00/rt2800usb.c       |   54 ++-
 drivers/net/wireless/rt2x00/rt2x00.h          |   16 +-
 drivers/net/wireless/rt2x00/rt2x00config.c    |   12 +-
 drivers/net/wireless/rt2x00/rt2x00crypto.c    |   17 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c       |   63 ++--
 drivers/net/wireless/rt2x00/rt2x00firmware.c  |    3 +
 drivers/net/wireless/rt2x00/rt2x00ht.c        |   10 +
 drivers/net/wireless/rt2x00/rt2x00queue.c     |    7 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h     |    8 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c       |  135 ++++--
 drivers/net/wireless/rt2x00/rt61pci.c         |   10 +-
 drivers/net/wireless/rt2x00/rt73usb.c         |    4 +-
 drivers/net/wireless/rtl818x/rtl8180_dev.c    |  143 +++---
 drivers/net/wireless/rtl818x/rtl8187_dev.c    |    9 +-
 drivers/net/wireless/wl12xx/wl1251_acx.c      |    2 +-
 drivers/net/wireless/wl12xx/wl1251_acx.h      |    8 +-
 drivers/net/wireless/wl12xx/wl1251_boot.c     |    2 +-
 drivers/net/wireless/wl12xx/wl1251_cmd.c      |    2 +-
 drivers/net/wireless/wl12xx/wl1251_cmd.h      |    6 +-
 drivers/net/wireless/wl12xx/wl1251_event.c    |   29 +
 drivers/net/wireless/wl12xx/wl1251_event.h    |    1 +
 drivers/net/wireless/wl12xx/wl1251_main.c     |   37 +-
 drivers/net/wireless/wl12xx/wl1251_tx.c       |    4 +-
 drivers/net/wireless/wl12xx/wl1271_acx.c      |    2 +-
 drivers/net/wireless/wl12xx/wl1271_main.c     |   13 +-
 drivers/net/wireless/wl12xx/wl1271_tx.c       |    4 +-
 drivers/net/wireless/zd1211rw/zd_chip.c       |    5 +
 include/linux/netdevice.h                     |    2 +
 include/linux/nl80211.h                       |  150 +++++--
 include/linux/ssb/ssb_regs.h                  |    1 +
 include/net/cfg80211.h                        |  179 ++++++-
 include/net/mac80211.h                        |   60 ++-
 net/core/net-sysfs.c                          |    3 +-
 net/mac80211/aes_ccm.c                        |    6 +-
 net/mac80211/aes_cmac.c                       |    6 +-
 net/mac80211/agg-rx.c                         |   22 +
 net/mac80211/cfg.c                            |   62 +--
 net/mac80211/debugfs_key.c                    |   55 +--
 net/mac80211/driver-trace.h                   |    4 +-
 net/mac80211/ht.c                             |   28 +
 net/mac80211/ibss.c                           |    8 +-
 net/mac80211/ieee80211_i.h                    |   20 +-
 net/mac80211/iface.c                          |   63 ++-
 net/mac80211/key.c                            |   59 +--
 net/mac80211/key.h                            |    4 +-
 net/mac80211/main.c                           |   81 +++-
 net/mac80211/mlme.c                           |   28 +-
 net/mac80211/rc80211_pid_debugfs.c            |    2 +-
 net/mac80211/rx.c                             |  503 ++++++++++++-----=
-
 net/mac80211/scan.c                           |   32 +-
 net/mac80211/sta_info.h                       |   16 +-
 net/mac80211/status.c                         |    2 +-
 net/mac80211/tx.c                             |   22 +-
 net/mac80211/util.c                           |    6 +-
 net/mac80211/wep.c                            |    2 +-
 net/mac80211/work.c                           |   39 +-
 net/mac80211/wpa.c                            |   32 +-
 net/wireless/core.c                           |   15 +-
 net/wireless/core.h                           |   21 +-
 net/wireless/mlme.c                           |  149 ++++--
 net/wireless/nl80211.c                        |  123 ++++-
 net/wireless/nl80211.h                        |   14 +-
 net/wireless/reg.c                            |   16 +-
 net/wireless/sysfs.c                          |    9 +
 net/wireless/util.c                           |    4 +-
 158 files changed, 4631 insertions(+), 2844 deletions(-)
 create mode 100644 Documentation/DocBook/80211.tmpl
 delete mode 100644 Documentation/DocBook/mac80211.tmpl
 create mode 100644 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-tt.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-tt.h

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2010-08-25.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
