From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2010-04-23
Date: Fri, 23 Apr 2010 15:01:40 -0400
Message-ID: <20100423190139.GA7276@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Yet another huge batch of updates intended for 2.6.35.  The ath9k driver
in particular gets a lot of attention, and the iwlwifi team continues
its usual strong showing.

Please let me know if there are problems!  Again, this is for the
'for-davem' branch where I have pre-resolved some merge conflicts.

Thanks,

John

---

The following changes since commit c68ed255265968c3948fa2678bf59d15c471b055:
  Tom Herbert (1):
        bnx2x: add support for receive hashing

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git for-davem

Abhijeet Kolekar (1):
      iwlwifi: add debugfs ops to iwlwifi

Benoit Papillault (1):
      ath5k/ath9k: Fix 64 bits TSF reads

Christian Lamparter (1):
      p54pci: fix serious sparse warning

Dan Williams (2):
      libertas: consolidate SDIO firmware wait code
      libertas: Davinci platforms need more time loading helper firmware

Daniel Halperin (1):
      mac80211: fix typo in comments

Daniel Yingqiang Ma (1):
      ath9k: Group Key fix for VAPs

David Kilroy (3):
      orinoco: implement set_wiphy_params
      orinoco: use cfg80211_find_ie
      orinoco: have sparse check endian issues

Felix Fietkau (23):
      ath9k_hw: add silicon revision macros for AR9300
      ath9k_hw: add a macro for abstracting generic timer access
      ath9k_hw: fix a missing hex prefix for a register mask
      ath9k_hw: add simple register abstraction for some AR9300 registers
      ath9k_hw: add support for GPIO differences on AR9003
      ath9k_hw: Add AR9003 PHY register definitions
      ath9k_hw: Set the channel on AR9003
      ath9k_hw: Implement PLL control on AR9003
      ath9k_hw: Implement spur mitigation on AR9003
      ath9k_hw: Split off ANI control to the PHY ops
      ath9k: Add Rx EDMA support
      ath9k_hw: Split out the function for reading the noise floor
      ath9k_hw: move AR9280 PCI EEPROM fix to eeprom_def.c
      ath9k_hw: Update ath9k_hw_set_dma for AR9300
      ath9k: check for specific rx stuck conditions and recover from them
      ath9k: clean up tx buffer handling
      ath9k: update the MCS mask for MCS16 and above
      ath9k: update the ath_max_4ms_framelen table
      ath9k: reduce the bits_per_symbol table size, support more streams
      ath9k: initialize the number of tx/rx streams correctly
      mac80211: add flags for STBC (Space-Time Block Coding)
      ath9k: add support for Tx and Rx STBC
      ath9k: set the STBC flag in rate control if the peer supports it

Grazvydas Ignotas (3):
      wl1251: read default MAC address from EEPROM when available
      wl1251: register platform_device to pass board data
      wl1251: add support for dedicated IRQ line

Helmut Schaa (2):
      rt2x00: add txdesc parameter to write_tx_data
      rt2x00: rt2800pci: fix tx path by not accessing the skb after it was DMA mapped

Holger Schurig (2):
      mac80211: sample survey implementation for mac80211 & hwsim
      ath5k: basic support for survey

Johannes Berg (14):
      iwlwifi: remove scan_bands logic
      iwlwifi: correct atomic bitops usage
      iwlwifi: remove next_scan_jiffies
      iwlwifi: remove scan_pass_start
      iwlwifi: rename priv->scan to priv->scan_cmd
      iwlwifi: trigger scan synchronously
      iwlwifi: make BT coex config a virtual method
      iwlwifi: rename TX_CMD_FLG_BT_DIS_MSK
      iwlwifi: don't check monitor for scanning
      iwlwifi: remove monitor check
      iwlwifi: make scan antenna forcing more generic
      mac80211: fix stopping RX BA session from timer
      mac80211: add missing newline
      radiotap parser: fix endian annotation

John W. Linville (2):
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlwifi/iwlwifi-2.6
      Merge branch 'master' into for-davem

Juuso Oikarinen (2):
      mac80211: Prevent running sta_cleanup timer unnecessarily
      mac80211: Fix ieee80211_sta_conn_mon_timer with hw connection monitoring

Larry Finger (1):
      rtl818x: Move configuration details to the rtl818x directory

Luis R. Rodriguez (54):
      ath9k_hw: start building an abstraction layer for hardware routines
      ath9k_hw: AR9003 does not have AR_RC_AHB skip its setting
      ath9k_hw: remove wrapper ath9k_hw_write_regs()
      ath9k_hw: Move some RF ops to the private callbacks
      ath9k_hw: skip PLL initialization on AR9003 on Power-On-Reset
      ath9k_hw: add some comments for ath9k_set_power_network_sleep()
      ath9k_hw: add a private callback for PLL control computation
      ath9k_hw: Add AR9003 PHY support
      ath9k_hw: move init config and default after chip is up
      ath9k_hw: add the AR9003 ar9003_hw_macversion_supported()
      ath9k_hw: disable ANI for AR9003
      ath9k: disable the MIB interrupt if ANI is disabled
      ath9k_hw: add common channel select helpers for ar900[23]
      ath9k_hw: split initvals.h by hardware family
      ath9k_hw: add initvals for the AR9003 hardware family
      ath9k_hw: add helpers for processing the AR9003 INI
      ath9k_hw: add all the AR9003 PHY callbacks
      ath9k_hw: add a helper for Power Amplifier calibration for AR9002
      ath9k_hw: add a helper for the OLC tem compensation for AR9002
      ath9k_hw: rename PA calib for AR9287
      ath9k_hw: shift code for AR9280 OLC temp comp
      ath9k_hw: move the AR9280 OLC temp comp to its own helper
      ath9k_hw: simplify OLC temp compensation for AR9002
      ath9k_hw: rename the PA calib routines to match their families
      ath9k_hw: rename getNoiseFloorThresh() to ath9k_hw_loadnf()
      ath9k_hw: move the cal AR9100 calibration settings
      ath9k_hw: split calib code by hardware families
      ath9k_hw: add the AR9003 ar9003_hw_init_cal callback
      ath9k_hw: add the config_pci_powersave AR9003 callback
      ath9k_hw: split the generic hardware code by hardware family
      ath9k_hw: move the cck channel 14 INI to the AR9002 hw code
      ath9k_hw: move TX/RX gain INI stuff to its own hardware family code
      ath9k_hw: abstract the AR_PHY_AGC_CONTROL register access
      ath9k_hw: abstract loading noisefloor
      ath9k_hw: fill in the callbacks for calibration for AR9003
      ath9k_hw: complete AR9003 calibration
      ath9k_hw: rename eep_AR9287_ops to eep_ar9287_ops
      ath9k_hw: restore mac address reading logic
      ath9k_hw: add OFDM spur mitigation for AR9003
      ath9k_hw: move the RF claim stuff to AR9002 hardware family
      ath9k_hw: add the AR9300 SREV hw name print
      ath9k_hw: add TX/RX gain register initialization for AR9003
      ath9k_hw: skip asynch fifo enablement to AR9003
      ath9k_hw: skip WEP aggregation enable code for AR9003
      ath9k_hw: move AR9002 mac ops to its own file
      ath9k: add RXLP and RXHP to debugfs counters
      ath9k_hw: enable CRC check of descriptors for AR9003
      ath9k_hw: set cwmin and cwmax to 0 for for AR9003 upon txq reset
      mac80211: add LDPC control flag
      ath9k_hw: add LDPC support for AR9003
      ath9k: add LDPC support
      ath9k_hw: add the PCI ID for the first AR9300 device
      ath9k_hw: make two initvals consto for the AR9001 family
      ath9k_hw: make all AR9002 initvals use u32

Nishant Sarmukadam (1):
      cfg80211: Avoid sending IWEVASSOCREQIE and IWEVASSOCRESPIE events with NULL event body

Reinette Chatre (1):
      Merge branch 'wireless-2.6' into wireless-next-2.6

Samuel Ortiz (2):
      iwmc3200wifi: Fix sparse warnings
      iwmc3200wifi: check sparse endianness annotations

Senthil Balasubramanian (5):
      ath9k_hw: Add the PCI IDs for AR9300 and fill up the pci_id_tables
      ath9k_hw: update the chip tests for AR9003
      ath9k_hw: prevent reset control register zeroing on AR9003 reset
      ath9k_hw: the eep_map is used only for AR9280 PCI card ini fixup
      ath9k_hw: Implement AR9003 eeprom callbacks

Shanyu Zhao (2):
      iwlwifi: bring up 6000 Series 2x2 AGN Gen2 adapters
      iwlwifi: remove redundant iwl_dump_lq_cmd()

Stanislaw Gruszka (3):
      iwlwifi: check scan request ie_len
      iwlwifi: initialize iwl_wimax_coex_cmd.flags
      mac80211: document IEEE80211_CONF_CHANGE_QOS

Sujith (10):
      ath9k_htc: Cleanup beacon configuration
      ath: Add buffered register write operations
      ath9k_htc: Implement multiple register write support
      ath9k_hw: Add macros for multiple register writes
      ath9k_hw: Relocate Opmode initialization
      ath9k_hw: Use buffered register writes
      ath9k_htc: Remove GPIO set on unload
      ath9k_htc: Add dropped SKB count to debugfs
      ath9k_htc: Handle WMI timeouts properly
      ath9k_htc: Fix sparse endian warnings

Vasanthakumar Thiagarajan (26):
      ath9k_hw: Add hw cap flag for EDMA for the AR9003 family
      ath9k_hw: Fill few hw cap for edma
      ath9k_hw: Add abstraction for rx enable
      ath9k_hw: Fill rx_enable() for the AR9003 hardware family
      ath9k_hw: Add few routines for rx edma support
      ath9k_hw: Define tx control struct for AR9003
      ath9k_hw: Move code which populates ds_data to ath9k_hw
      ath9k_hw: Add abstraction to set/get link pointer
      ath9k: Use abstraction to get link pointer
      ath9k: Use memcpy in ath_clone_txbuf()
      ath9k: Remove ATH9K_TX_SW_ABORTED and introduce a bool for this purpose
      ath9k: Make bf_desc of ath_buf opaque
      ath9k_hw: Abstract the routine which returns interrupt status
      ath9k_hw: Initialize interrupt mask for AR9003
      ath9k_hw: Fill get_isr() for AR9003
      ath9k_hw: Configure Tx interrupt mitigation timer
      ath9k: Load SW filtered NF values and start NF cal during full reset for AR9003
      ath9k_hw: Define abstraction for tx desc access
      ath9k_hw: Add function to configure tx status ring buffer
      ath9k_hw: Fill descriptor abstrations for AR9003
      ath9k: Setup appropriate tx desc for regular dma and edma
      ath9k: Initialize and configure tx status for EDMA
      ath9k_hw: Compute pointer checksum over the link descriptor
      ath9k: Add Tx EDMA support
      ath9k: Enable TXOK and TXERR interrupts for TX EDMA
      ath9k_hw: Abort rx if hw is not coming out of full sleep in reset

Wey-Yi Guy (7):
      iwlwifi: set correct single/dual stream mask
      iwlwifi: more generic eeprom defines
      iwlwifi: remove duplicated debug functions
      iwlwifi: add hw revision for 6000g2 NIC
      iwlwifi: PA type for 6000g2 series
      iwlwifi: sanity check for turn on aggregation tid
      iwlwifi: more code clean up for agn devices

Xose Vazquez Perez (2):
      wireless: rt2x00: rt2800usb: identify Hawking devices
      wireless: rt2x00: rt2800usb: identify Allwin devices

 drivers/net/wireless/Kconfig                       |   85 +-
 drivers/net/wireless/ath/ath.h                     |   14 +-
 drivers/net/wireless/ath/ath5k/base.c              |   19 +
 drivers/net/wireless/ath/ath5k/pcu.c               |   31 +-
 drivers/net/wireless/ath/ath9k/Makefile            |   16 +-
 drivers/net/wireless/ath/ath9k/ani.c               |  208 +--
 drivers/net/wireless/ath/ath9k/ar5008_initvals.h   |  742 +++++++
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        | 1375 +++++++++++++
 drivers/net/wireless/ath/ath9k/ar9001_initvals.h   | 1254 ++++++++++++
 drivers/net/wireless/ath/ath9k/ar9002_calib.c      | 1000 ++++++++++
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |  593 ++++++
 .../ath/ath9k/{initvals.h => ar9002_initvals.h}    | 2052 +-------------------
 drivers/net/wireless/ath/ath9k/ar9002_mac.c        |  480 +++++
 drivers/net/wireless/ath/ath9k/ar9002_phy.c        |  539 +++++
 drivers/net/wireless/ath/ath9k/ar9002_phy.h        |  572 ++++++
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |  802 ++++++++
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     | 1856 ++++++++++++++++++
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |  323 +++
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |  205 ++
 drivers/net/wireless/ath/ath9k/ar9003_initvals.h   | 1793 +++++++++++++++++
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |  611 ++++++
 drivers/net/wireless/ath/ath9k/ar9003_mac.h        |  120 ++
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        | 1142 +++++++++++
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |  847 ++++++++
 drivers/net/wireless/ath/ath9k/ath9k.h             |   24 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |    5 +-
 drivers/net/wireless/ath/ath9k/calib.c             | 1089 +----------
 drivers/net/wireless/ath/ath9k/calib.h             |   19 +-
 drivers/net/wireless/ath/ath9k/common.h            |    4 +-
 drivers/net/wireless/ath/ath9k/debug.c             |   22 +-
 drivers/net/wireless/ath/ath9k/debug.h             |    4 +
 drivers/net/wireless/ath/ath9k/eeprom.c            |    9 +-
 drivers/net/wireless/ath/ath9k/eeprom.h            |   22 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |   17 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |    9 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |   13 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c           |   13 +-
 drivers/net/wireless/ath/ath9k/htc.h               |   19 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |   29 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |  104 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   20 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |   11 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c           |    8 +-
 drivers/net/wireless/ath/ath9k/htc_hst.h           |   24 +-
 drivers/net/wireless/ath/ath9k/hw-ops.h            |  280 +++
 drivers/net/wireless/ath/ath9k/hw.c                | 1761 ++++-------------
 drivers/net/wireless/ath/ath9k/hw.h                |  253 +++-
 drivers/net/wireless/ath/ath9k/init.c              |   83 +-
 drivers/net/wireless/ath/ath9k/mac.c               |  490 ++---
 drivers/net/wireless/ath/ath9k/mac.h               |   67 +-
 drivers/net/wireless/ath/ath9k/main.c              |   82 +-
 drivers/net/wireless/ath/ath9k/pci.c               |    1 +
 drivers/net/wireless/ath/ath9k/phy.c               |  978 ----------
 drivers/net/wireless/ath/ath9k/phy.h               |  584 +------
 drivers/net/wireless/ath/ath9k/rc.c                |   13 +
 drivers/net/wireless/ath/ath9k/recv.c              |  518 ++++-
 drivers/net/wireless/ath/ath9k/reg.h               |  167 ++-
 drivers/net/wireless/ath/ath9k/wmi.c               |   16 +-
 drivers/net/wireless/ath/ath9k/wmi.h               |   19 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |  488 ++++--
 drivers/net/wireless/iwlwifi/Makefile              |    1 +
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    6 +
 drivers/net/wireless/iwlwifi/iwl-3945.c            |    2 +
 drivers/net/wireless/iwlwifi/iwl-3945.h            |    3 +
 drivers/net/wireless/iwlwifi/iwl-4965.c            |   15 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   11 +
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   34 +-
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c     |  834 ++++++++
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.h     |   56 +
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c        |    2 +
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |  403 ++++-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |   47 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |   42 +-
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c       |   36 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |   50 +-
 drivers/net/wireless/iwlwifi/iwl-agn.h             |    3 +
 drivers/net/wireless/iwlwifi/iwl-commands.h        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |   46 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   18 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |    1 +
 drivers/net/wireless/iwlwifi/iwl-debug.h           |    2 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |  770 +-------
 drivers/net/wireless/iwlwifi/iwl-dev.h             |    9 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |   32 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   80 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |  506 +-----
 drivers/net/wireless/iwlwifi/iwl-sta.c             |   13 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |   87 +-
 drivers/net/wireless/iwmc3200wifi/Makefile         |    2 +
 drivers/net/wireless/iwmc3200wifi/rx.c             |    3 +-
 drivers/net/wireless/iwmc3200wifi/trace.h          |    4 +-
 drivers/net/wireless/iwmc3200wifi/tx.c             |    4 +-
 drivers/net/wireless/libertas/if_sdio.c            |  103 +-
 drivers/net/wireless/mac80211_hwsim.c              |   28 +
 drivers/net/wireless/orinoco/Makefile              |    3 +
 drivers/net/wireless/orinoco/cfg.c                 |   88 +-
 drivers/net/wireless/orinoco/hw.c                  |   26 +
 drivers/net/wireless/orinoco/main.h                |   12 -
 drivers/net/wireless/orinoco/orinoco.h             |    2 +
 drivers/net/wireless/orinoco/scan.c                |    4 +-
 drivers/net/wireless/orinoco/wext.c                |  183 +--
 drivers/net/wireless/p54/p54pci.c                  |    2 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |   34 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |   26 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |    3 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |    3 +-
 drivers/net/wireless/rt2x00/rt2x00pci.h            |    3 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |    3 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |    3 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h            |    3 +-
 drivers/net/wireless/rtl818x/Kconfig               |   88 +
 drivers/net/wireless/wl12xx/wl1251_main.c          |   63 +
 drivers/net/wireless/wl12xx/wl1251_reg.h           |    7 +
 drivers/net/wireless/wl12xx/wl1251_sdio.c          |   96 +-
 include/linux/ieee80211.h                          |    1 +
 include/linux/spi/wl12xx.h                         |    2 +
 include/net/cfg80211.h                             |    2 +-
 include/net/mac80211.h                             |   17 +-
 net/mac80211/agg-rx.c                              |   18 +-
 net/mac80211/agg-tx.c                              |    2 +-
 net/mac80211/cfg.c                                 |   12 +
 net/mac80211/driver-ops.h                          |    9 +
 net/mac80211/key.c                                 |    1 +
 net/mac80211/mlme.c                                |    5 +
 net/mac80211/sta_info.c                            |   13 +-
 net/mac80211/tx.c                                  |    7 +
 net/wireless/sme.c                                 |   16 +-
 127 files changed, 19021 insertions(+), 8935 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/ar5008_initvals.h
 create mode 100644 drivers/net/wireless/ath/ath9k/ar5008_phy.c
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9001_initvals.h
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9002_calib.c
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9002_hw.c
 rename drivers/net/wireless/ath/ath9k/{initvals.h => ar9002_initvals.h} (78%)
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9002_mac.c
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9002_phy.c
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9002_phy.h
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9003_calib.c
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9003_hw.c
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9003_initvals.h
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9003_mac.c
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9003_mac.h
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9003_phy.c
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9003_phy.h
 create mode 100644 drivers/net/wireless/ath/ath9k/hw-ops.h
 delete mode 100644 drivers/net/wireless/ath/ath9k/phy.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.h
 create mode 100644 drivers/net/wireless/rtl818x/Kconfig

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2010-04-23.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
