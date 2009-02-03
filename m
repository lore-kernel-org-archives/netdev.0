From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2009-02-03
Date: Tue, 3 Feb 2009 15:25:04 -0500
Message-ID: <20090203202504.GD10968@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42501 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbZBCUat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 15:30:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is the somewhat overdue dump of pending wireless updates intended
for 2.6.30.  I apologize for not getting it to you sooner, but I kept
needing to rebase it upon fixes sent to 2.6.29.  After that it was big
enough that I wanted it to see a copule of linux-next builds (which it
now has seen).  And of course, all of these patches have done time in
wireless-testing as well...

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit a73efd0a8552927ebe5dff84936f7fdac4f7e314:
  Divy Le Ray (1):
        iw_cxgb3: handle chip reset notifications

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Abbas, Mohamed (3):
      iwlwifi: allow user to set max rate
      iwlagn: fix agn rate scaling
      iwl3945: fix deep sleep when removing the driver.

Abhijeet Kolekar (6):
      iwl3945: use iwl_rx_mem_buffer
      iwl3945: use iwl_rx_queue in iwl3945
      iwl3945: use iwl_hw_params in iwl3945_priv
      iwl3945: rename iwl3945_priv variables
      iwl3945: replaces iwl3945_priv with iwl_priv
      iwl3945: use iwl-io.h and delete iwl-3945-io.h

Alina Friedrichsen (10):
      mac80211: Disallow to set multicast BSSID
      mac80211: Don't scan if BSSID and channel are set manually
      mac80211: Don't merge if BSSID is set manually
      mac80211: Allow to set channel in adhoc properly
      mac80211: Read the TSF via debugfs
      ath5k: Read and write the TSF via debugfs
      ath9k: Read and write the TSF via debugfs
      mac80211: Fixed BSSID handling revisited
      mac80211: Generic TSF debugging
      b43: Accessing the TSF via mac80211

Andrew Price (1):
      rt2400,rt2500: init led_qual for LED_MODE_DEFAULT

Andrey Borzenkov (3):
      Move orinoco Kconfig entries into drivers/net/wireless/orinoco/Kconfig
      orinoco: convert to struct net_device_ops
      orinoco: trivial cleanup in alloc_orinocodev

Andrey Yurovsky (1):
      rt2x00: Add mesh support

Bob Copeland (11):
      ath5k: support LEDs on Acer Aspire One netbook
      ath5k: fix off-by-one in gpio checks
      mac80211: document return codes from ops callbacks
      ath5k: fix bf->skb==NULL panic in ath5k_tasklet_rx
      mac80211: add suspend/resume callbacks
      ath5k: remove stop/start calls from within suspend/resume
      ath5k: remove unused led_off parameter
      ath5k: use short preamble when possible
      ath5k: honor the RTS/CTS bits
      mac80211: change workqueue back to non-freezeable
      mac80211: flush workqueue a second time in suspend()

Chatre, Reinette (2):
      iwl3945: add debugging for wrong command queue
      iwlwifi: add test to determine if interface in monitor mode

Christian Lamparter (17):
      p54: label queues with their corresponding names
      p54: enable proper frame injection
      p54usb: utilize usb_reset_device for 3887
      p54: prevent upload of wrong firmwares
      p54: regulatory domain hints
      p54: enable rx/tx antenna diversity by eeprom bits
      p54: implement FIF_OTHER_BSS filter setting
      p54: power save management
      p54: return NETDEV_TX_OK in p54_tx and fix sparse warnings
      p54: refactor p54_alloc_skb
      p54: upgrade memrecord to p54_tx_info
      p54: prepare the eeprom parser routines for longbow
      p54: longbow frontend support
      p54spi: stlc45xx eeprom blob
      p54spi: p54spi driver
      p54usb: fix conflict with recent usb changes
      p54spi: remove arch specific dependencies

Colin McCabe (2):
      libertas: Update libertas core with GSPI constants
      libertas: if_spi, driver for libertas GSPI devices

Dan Williams (8):
      libertas: fix CF firmware loading for some cards
      airo: clean up and clarify interrupt-time task handling
      airo: re-arrange WPA capability checks
      airo: simplify WEP index and capability checks
      airo: clean up WEP key operations
      airo: use __attribute__ ((packed)) not #pragma
      airo: clean up and clarify micinit()
      airo: remove useless #defines

David Kilroy (2):
      wireless: Add channel/frequency conversions to ieee80211.h
      orinoco: Remove unused variable rx_data

Gabor Juhos (12):
      ath9k: use signed format to print HAL status
      ath9k: convert to struct device
      ath9k: convert to use bus-agnostic DMA routines
      ath9k: introduce bus specific cache size routine
      ath9k: introduce bus specific cleanup routine
      ath9k: move PCI code into separate file
      ath9k: introduce platform driver for AHB bus support
      ath9k: get EEPROM contents from platform data on AHB bus
      ath9k: remove (u16) casts from rtc register access
      ath9k: fix ar5416Addac_9100 values
      ath9k: fix null pointer dereference in ani monitor code
      ath9k: enable support for AR9100

Harvey Harrison (1):
      prism54: remove private implementation of le32_add_cpu

Helmut Schaa (4):
      ath5k: discard 11g caps if reported by an ar5211 eeprom
      iwl3945: report killswitch changes even if the interface is down
      iwl3945: fix some warnings when compiled without debug
      iwlagn: fix hw-rfkill while the interface is down

Ivo van Doorn (21):
      rt2x00: Implement Powersaving
      rt2x00: Move link tuning into seperate file
      rt2x00: Reduce calls to bbp_read()
      rt2x00: Restrict interface between rt2x00link and drivers
      rt2x00: Add RFKILL support to rt2500usb and rt73usb
      rt2x00: Rename CONFIG_CRYPTO_COPY_IV
      rt2x00: Implement WDS support
      rt2x00: Split EEPROM_NIC_TX_RX_FIXED
      rt2x00: Move code into seperate functions
      rt2x00: Remove ENTRY_TXD_OFDM_RATE
      rt2x00: Allow drivers to pass the noise value during rxdone
      rt2x00: Introduce RXDONE_SIGNAL_MASK mask
      rt2x00: Release rt2x00 2.3.0
      rt2x00: Replace RFKILL with INPUT
      rt2x00: Only register rfkill input when key is present
      rt2x00: Update copyright year to 2009
      rt2x00: conf_tx() only need register access for WMM queues
      rt2x00: Add LED_MODE_ASUS support
      rt2x00: rt2x00_rev() should return u32
      rt2x00: Restrict firmware file lengths
      rt2x00: Simplify suspend/resume handling

Jay Sternberg (4):
      iwlwifi: correct Kconfig to prevent following entries from not indenting
      iwlwifi: remove static from 5000 structures
      iwlwifi: add recognition of Intel WiFi Link 6000 and 6050 Series
      iwlwifi: add recognition of Intel WiFi Link 100 Series

Jiri Slaby (1):
      IWL: fix WARN typo

Johannes Berg (15):
      ssb/b43: add new N PHY device
      b43: detect N PHY revision/radio
      mac80211: clean up set_key callback
      mac80211: remove user_power_level from driver API
      mac80211: clarify alignment docs, fix up alignment
      mac80211: clean up channel type config
      mac80211: validate SIOCSIWPOWER arguments better
      mac80211: move dynamic PS timeout to hardware config
      mac80211: extend/document powersave API
      cfg80211: add PM hooks
      mac80211: constify ieee80211_if_conf.bssid
      wireless: restrict to 32 legacy rates
      mac80211: Add capability to enable/disable beaconing
      mac80211: add interface list lock
      mac80211: don't try to powersave/config disabled interfaces

Jouni Malinen (23):
      mac80211: 802.11w - STA flag for MFP
      mac80211: 802.11w - CCMP for management frames
      mac80211: 802.11w - Add BIP (AES-128-CMAC)
      mac80211: 802.11w - Use BIP (AES-128-CMAC)
      mac80211: 802.11w - WEXT parameter for setting mgmt cipher
      mac80211: 802.11w - WEXT configuration for IGTK
      mac80211: 802.11w - Configuration of MFP disabled/optional/required
      mac80211: 802.11w - SA Query processing
      mac80211: 802.11w - Do not force Action frames to disable encryption
      mac80211: 802.11w - Drop unprotected robust management frames if MFP is used
      mac80211: 802.11w - Implement Association Comeback processing
      mac80211: 802.11w - Optional software CCMP for management frames
      mac80211: 802.11w - Add driver capability flag for MFP
      ath9k: Fix set_key error codes
      ath9k: Setup MFP options for CCMP
      mac80211_hwsim: Report driver as MFP capable
      mac80211: Mark ieee80211_process_sa_query_req() static
      mac80211: Fix radiotap header it_present on big endian CPUs
      nl80211: Fix documentation errors
      ath9k: Use a defined value for pci_set_power_state()
      nl80211: New command for adding extra IE(s) into management frames
      mac80211: Fix drop-unencrypted for management frames
      mac80211: Fix MFP Association Comeback to use Timeout Interval IE

Kalle Valo (1):
      mac80211: make wake/stop_queue_by_reason() functions static

Kolekar, Abhijeet (15):
      iwl3945: Change IWLWIFI_VERSION constant name
      iwl3945: include iwl-core.h
      iwl3945: replace iwl_3945_cfg with iwl_cfg
      iwl3945: move structures from iwl-3945.h to iwl-dev.h
      iwl3945: remove duplicate structures from iwl-3945.h
      iwl3945: replace iwl3945_broadcast_addr with iwl_bcast_addr
      iwl3945: use iwl_mod_params for 3945
      iwl3945: cleanup and remove duplicate code
      iwl3945: add load ucode op
      iwl3945: add apm ops
      iwl3945: add set_pwr_src
      iwl3945: simplify iwl3945_pci_probe
      iwl3945: release resources before shutting down
      iwl3945: use iwl_get_hw_mode
      iwl3945: adding utils ops

Larry Finger (4):
      b43: Eliminate compilation warning in b43_op_set_key
      rtl8187: Fix locking of private data
      rtl8187: Increase receive queue depth
      rtl8187: Fix driver to return TX retry info for RTL8187L

Luis R. Rodriguez (33):
      mac80211: add HT conf helpers
      ath9k: use hw->conf on ath_setcurmode()
      ath9k: remove cache of rate preference when using 11g protection
      ath9k: Rename ath_setcurmode() to ath_cache_conf_rate()
      ath9k: consolidate arguments on hw reset
      ath9k: make request to get the noisefloor threshold band specific
      ath9k: use ieee80211_conf on ath9k_hw_iscal_supported()
      ath9k: make use of conf_is_ht*() in the rest of the driver
      iwlwifi: make use of conf_is_ht*() helpers
      mac80211: no need for ht.enabled
      ath9k: Make ANI CCK and OFDM error triggers band specific
      ath9k: remove mode specific default noise floor values
      ath9k: remove ath9k_hw_chan2wmode()
      ath9k: remove ath9k_hw_check_chan()
      ath9k: remove superfluous check on changing channel
      ath9k: fix sparse warnings
      cfg80211: call reg_notifier() once
      cfg80211: allow multiple driver regulatory_hints()
      cfg80211: fix typo on message after intersection
      cfg80211: add wiphy_apply_custom_regulatory()
      cfg80211: export freq_reg_info()
      cfg80211: process user requests only after previous user/driver/core requests
      cfg80211: ignore consecutive equal regulatory hints
      cfg80211: rename fw_handles_regulatory to custom_regulatory
      cfg80211: move check for ignore_reg_update() on wiphy_update_regulatory()
      cfg80211: pass more detailed regulatory request information on reg_notifier()
      cfg80211: Allow for strict regulatory settings
      mac80211: allow mac80211 drivers to get to struct ieee80211_hw from wiphy
      cfg80211: allow users to help a driver's compliance
      ath9k: simplify regulatory code
      ath9k: fix debug print on regd
      ath9k: remove useless ath9k driver version information
      cfg80211: do not pass -EALREADY to userspace on regdomain change request

Michael Buesch (7):
      b43: Fixup set_key handling
      b43: Use 64bit atomic register access for TSF
      b43/ssb: Add SPROM8 extraction and LP-PHY detection
      b43: Change schedule for old-fw support removal
      b43: Automatically probe for opensource firmware
      b43: Fix phy_g.c compiler warning
      b43: Dynamically control log verbosity

Nick Kossifidis (3):
      ath5k: Update EEPROM code
      ath5k: More EEPROM code updates
      ath5k: Minor QCU updates

Rami Rosen (7):
      mac80211: remove an unnecessary assignment to info in __ieee80211_tx().
      mac80211: remove an unused parameter in ieee80211_rx_mgmt_probe_req().
      mac80211: remove an unused definition (MAX_STA_COUNT) in sta_info.h.
      mac80211: remove unused variable in ieee80211_local (dot11WEPUndecryptableCount).
      mac80211: remove mesh_plink_close() method.
      mac80211: trivial documentation fixes (enum mesh_path_flags).
      mac80211: trivial documentation fix (mesh_nexthop_lookup()).

Reinette Chatre (1):
      iwlwifi: update copyright year to 2009

Rick Farrington (1):
      iwlagn: reduce off channel reception for 4965

Roel Kluin (1):
      ath5k: notice a negative keytype

Samuel Ortiz (26):
      iwl3945: Getting rid of iwl-3945-debug.h
      iwl3945: Remove DRV_NAME dependenies
      iwl3945: Getting rid of iwl3945_eeprom_channel
      iwl3945: Have consistant and not redefined HW constants
      iwl3945: Use iwl-agn-rs.h rates definitions.
      iwl3945: Getting rid of iwl-3945-led.h
      iwl3945: Remove power related definitions from 3945 code
      iwl3945: iwl3945_queue and iwl3945_channel_info replacement
      iwl3945: sync tx queue data structure with iwlagn
      iwl3945: switch to the iwl-core send_card_state routine
      iwl3945: Change crypto parameter name
      iwl3945: Fix iwl3945_init_drv()
      iwl3945: Use iwl_txq_update_write_ptr
      iwlwifi: Add TFD library operations
      iwl3945: Use iwl-hcmd host command routines
      iwl3945: Use iwl-rfkill
      iwl3945: Define send_tx_power
      iwl3945: Use iwlcore scan code
      iwlwifi: make iwl_tx_queue->tfds void*
      iwl3945: Use iwlcore TX queue management routines
      iwl3945: Use iwl-eeprom.c routines
      iwl3945: Use the iwlcore geos routines
      iwlwifi: Remove IWL3945_DEBUG
      iwl3945: Getting rid of priv->antenna
      iwl3945: Add restart_fw module parameter
      iwl3945: Remaining host command cleanups

Senthil Balasubramanian (2):
      ath9k: INI update for Atheros AR9280 and AR9285 chipset.
      ath9k: Fix AR9285 specific noise floor eeprom reads.

Sujith (19):
      mac80211: Add 802.11h CSA support
      ath9k: rateCodeToIndex is not used, remove it
      ath9k: Update short guard interval in rate control
      ath9k: Reorganize code in xmit.c
      ath9k: Remove ath_tx_stopdma and call ath9k_hw_stoptxdma directly
      ath9k: Merge queue draining functions
      ath9k: Add a helper function to wake mac80211 queues
      ath9k: Handle holding descriptor in TX completion properly
      ath9k: Revamp TX aggregation
      ath9k: Cleanup buffer type assignment
      mac80211: Add documentation bits for mac80211_rate_control_flags
      ath9k: Fix MCS rates registration bug for AR9285
      ath9k: Fix bug in rate control capability registration
      ath9k: Fix bug in NF calibration
      ath9k: Handle chainmask for A9280
      ath9k: Reconfigure beacons on getting a notification from mac80211
      ath9k: Fix station access in aggregation completion
      ath9k: Setup short preamble properly in rate registration
      ath9k: Fix bug in TX DMA termination

Tomas Winkler (7):
      iwlwifi: 3945 extract flow handler definitions into iwl-3945-fh.h
      iwlwifi: 3945 unfold iwl-3945-commands.h
      iwlwifi: use iwl-commands.h also in 3945
      iwlwifi: 3945 remove duplicated code from iwl-3945-commands.h
      iwlwifi: 3945 drop usage of union tsf
      iwlwifi: 3945 remove iwl-3945-commands.h
      iwlwifi: clean up printing

Tulio Magno Quites Machado Filho (1):
      ath5k: support LED's on emachines E510 notebook

Vasanthakumar Thiagarajan (9):
      mac80211: Scale down to non-HT association with TKIP/WEP as pairwise cipher
      mac80211: Fix tx power setting
      ath9k: Enable Bluetooth Coexistence support
      mac80211: Handle power constraint level advertised in 11d+h beacon
      ath9k: Fix basic connectivity issue
      ath9k: Fix typo in chip version check
      ath9k: Remove unnecessary gpio configuration in ath9k_hw_reset()
      ath9k: Remove unused ath9k_hw_select_antconfig() from hw.c
      ath9k: Clean up the way the eeprom antenna configuration is read

Vivek Natarajan (6):
      mac80211: Reset the power save timer from master_start_xmit.
      mac80211: A couple of fixes to dynamic power save.
      mac80211: Enhancements to dynamic power save.
      mac80211: Cancel the power save timer in ieee80211_stop.
      ath9k: Enable dynamic power save in ath9k.
      mac80211: Cancel the dynamic ps timer in ioctl_siwpower.

Wei Yongjun (1):
      mac80211: cleanup kmalloc/memset -> kcalloc

Winkler, Tomas (25):
      iwlwifi: move sysfs status entry to debugfs
      iwlwifi: kill retry_rate sysfs for iwlagn
      iwlwifi: 3945 remove current_rate from station entry.
      iwlwifi: emliminate iwl3945_mac_get_stats mac80211 handler
      iwlwifi: replace IWL_WARNING with IWL_WARN
      iwlwifi: replace IWL_ERROR with IWL_ERR
      iwlwifi: use iwl_cmd instead of iwl3945_cmd
      iwl3945: use iwl_rb_status
      iwl3945: rearrange 3945 tfd
      iwl3945: use iwl3945_tx_cmd instead of iwl_tx_cmd
      iwl3945: use rx queue management infrastructure from iwlcore
      iwl3945: kill hw_params.tx_ant_num
      iwl3945: kill iwl3945_rx_queue_restock
      iwl3945: kill iwl3945_rx_queue_space
      iwl3945: kill iwl3945_x2_queue_used
      iwl3945: remove double defined 3945 tfd structures
      iwl3945: use hw_params.rx_buf_size
      iwlwifi: make iwl-power.c more readable
      iwlwifi: fix iwl_mac_set_key and iwl3945_mac_set_key
      iwlwifi: kill iwl3945_scan_cancel and iwl3945_scan_cancel_timeout
      iwlwifi: kill scan39
      iwlwifi: remove unused or twice defined members in iwl_priv
      iwlwifi: eliminate power_data_39.
      iwlwifi: fix probe mask for 39 scan API
      iwlwifi: iwl_tx_queue_alloc : fix warning in printk formatting

Wu Fengguang (1):
      iwlwifi: beautify code

Zhu Yi (1):
      iwlwifi: add more comments to IWL_DL_xx

 Documentation/DocBook/mac80211.tmpl                |   12 +-
 Documentation/feature-removal-schedule.txt         |    4 +-
 drivers/net/wireless/Kconfig                       |  128 +-
 drivers/net/wireless/airo.c                        | 1137 +++---
 drivers/net/wireless/ath5k/ath5k.h                 |    1 +
 drivers/net/wireless/ath5k/base.c                  |  174 +-
 drivers/net/wireless/ath5k/base.h                  |    3 +-
 drivers/net/wireless/ath5k/caps.c                  |    6 +-
 drivers/net/wireless/ath5k/debug.c                 |   41 -
 drivers/net/wireless/ath5k/debug.h                 |    1 -
 drivers/net/wireless/ath5k/eeprom.c                |  150 +-
 drivers/net/wireless/ath5k/gpio.c                  |   10 +-
 drivers/net/wireless/ath5k/pcu.c                   |   24 +-
 drivers/net/wireless/ath5k/qcu.c                   |   47 +-
 drivers/net/wireless/ath9k/Makefile                |    2 +
 drivers/net/wireless/ath9k/ahb.c                   |  187 +
 drivers/net/wireless/ath9k/ani.c                   |   18 +-
 drivers/net/wireless/ath9k/ath9k.h                 |   71 +-
 drivers/net/wireless/ath9k/beacon.c                |   30 +-
 drivers/net/wireless/ath9k/calib.c                 |  214 +-
 drivers/net/wireless/ath9k/core.h                  |   87 +-
 drivers/net/wireless/ath9k/debug.c                 |    1 +
 drivers/net/wireless/ath9k/eeprom.c                |  150 +-
 drivers/net/wireless/ath9k/hw.c                    |  354 +-
 drivers/net/wireless/ath9k/hw.h                    |   21 +-
 drivers/net/wireless/ath9k/initvals.h              |  565 ++--
 drivers/net/wireless/ath9k/mac.c                   |   31 +-
 drivers/net/wireless/ath9k/main.c                  | 1016 ++---
 drivers/net/wireless/ath9k/pci.c                   |  305 ++
 drivers/net/wireless/ath9k/rc.c                    |   25 +-
 drivers/net/wireless/ath9k/rc.h                    |    1 -
 drivers/net/wireless/ath9k/recv.c                  |   36 +-
 drivers/net/wireless/ath9k/reg.h                   |   27 +-
 drivers/net/wireless/ath9k/regd.c                  | 1188 ++----
 drivers/net/wireless/ath9k/regd.h                  |  181 +-
 drivers/net/wireless/ath9k/regd_common.h           | 2058 ++--------
 drivers/net/wireless/ath9k/xmit.c                  | 2878 ++++++--------
 drivers/net/wireless/atmel.c                       |   20 +-
 drivers/net/wireless/b43/Kconfig                   |   14 +-
 drivers/net/wireless/b43/b43.h                     |   37 +-
 drivers/net/wireless/b43/debugfs.c                 |   44 +-
 drivers/net/wireless/b43/debugfs.h                 |    5 +-
 drivers/net/wireless/b43/main.c                    |  378 ++-
 drivers/net/wireless/b43/main.h                    |   25 +
 drivers/net/wireless/b43/phy_g.c                   |    3 +
 drivers/net/wireless/b43legacy/main.c              |    2 +-
 drivers/net/wireless/iwlwifi/Kconfig               |   53 +-
 drivers/net/wireless/iwlwifi/Makefile              |    2 +
 drivers/net/wireless/iwlwifi/iwl-100.c             |   70 +
 drivers/net/wireless/iwlwifi/iwl-3945-commands.h   | 1702 --------
 drivers/net/wireless/iwlwifi/iwl-3945-debug.h      |  167 -
 drivers/net/wireless/iwlwifi/iwl-3945-fh.h         |  188 +
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h         |  221 +-
 drivers/net/wireless/iwlwifi/iwl-3945-io.h         |  404 --
 drivers/net/wireless/iwlwifi/iwl-3945-led.c        |  109 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.h        |   40 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c         |   93 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.h         |  206 -
 drivers/net/wireless/iwlwifi/iwl-3945.c            | 1038 +++--
 drivers/net/wireless/iwlwifi/iwl-3945.h            |  759 +----
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h         |   40 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c            |   64 +-
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h         |   14 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   59 +-
 .../iwlwifi/{iwl-3945-core.h => iwl-6000-hw.h}     |   59 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |  130 +
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd-check.c  |   27 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |  106 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h          |   55 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  538 ++--
 drivers/net/wireless/iwlwifi/iwl-calib.c           |    8 +-
 drivers/net/wireless/iwlwifi/iwl-calib.h           |    4 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |  505 +++-
 drivers/net/wireless/iwlwifi/iwl-core.c            |  169 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   55 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |  172 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   23 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |  135 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |   26 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |    7 +-
 drivers/net/wireless/iwlwifi/iwl-fh.h              |   21 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |   24 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h         |    2 +-
 drivers/net/wireless/iwlwifi/iwl-io.h              |   22 +-
 drivers/net/wireless/iwlwifi/iwl-led.c             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-led.h             |    6 +-
 drivers/net/wireless/iwlwifi/iwl-power.c           |   61 +-
 drivers/net/wireless/iwlwifi/iwl-power.h           |   18 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-rfkill.c          |    9 +-
 drivers/net/wireless/iwlwifi/iwl-rfkill.h          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c              |   23 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   52 +-
 drivers/net/wireless/iwlwifi/iwl-spectrum.c        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-spectrum.h        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c             |   59 +-
 drivers/net/wireless/iwlwifi/iwl-sta.h             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              |  233 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        | 4242 ++++++--------------
 drivers/net/wireless/libertas/Makefile             |    2 +
 drivers/net/wireless/libertas/defs.h               |    2 +
 drivers/net/wireless/libertas/host.h               |    1 +
 drivers/net/wireless/libertas/hostcmd.h            |    8 +
 drivers/net/wireless/libertas/if_cs.c              |    2 +-
 drivers/net/wireless/libertas/if_spi.c             | 1203 ++++++
 drivers/net/wireless/libertas/if_spi.h             |  208 +
 drivers/net/wireless/libertas/main.c               |    5 +-
 drivers/net/wireless/libertas_tf/cmd.c             |    2 +-
 drivers/net/wireless/libertas_tf/libertas_tf.h     |    2 +-
 drivers/net/wireless/mac80211_hwsim.c              |    2 +
 drivers/net/wireless/orinoco/Kconfig               |  120 +
 drivers/net/wireless/orinoco/orinoco.c             |   63 +-
 drivers/net/wireless/orinoco/orinoco.h             |    9 -
 drivers/net/wireless/p54/Kconfig                   |   10 +
 drivers/net/wireless/p54/Makefile                  |    1 +
 drivers/net/wireless/p54/p54.h                     |   38 +-
 drivers/net/wireless/p54/p54common.c               |  631 +++-
 drivers/net/wireless/p54/p54common.h               |  125 +-
 drivers/net/wireless/p54/p54pci.c                  |    6 +
 drivers/net/wireless/p54/p54spi.c                  |  770 ++++
 drivers/net/wireless/p54/p54spi.h                  |  125 +
 drivers/net/wireless/p54/p54spi_eeprom.h           |  678 ++++
 drivers/net/wireless/p54/p54usb.c                  |   87 +-
 drivers/net/wireless/p54/p54usb.h                  |    1 +
 drivers/net/wireless/prism54/islpci_eth.c          |    5 +-
 drivers/net/wireless/prism54/islpci_mgt.h          |    6 -
 drivers/net/wireless/rndis_wlan.c                  |   13 +-
 drivers/net/wireless/rt2x00/Kconfig                |    7 +-
 drivers/net/wireless/rt2x00/Makefile               |    1 +
 drivers/net/wireless/rt2x00/rt2400pci.c            |   70 +-
 drivers/net/wireless/rt2x00/rt2400pci.h            |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |   98 +-
 drivers/net/wireless/rt2x00/rt2500pci.h            |    2 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |   68 +-
 drivers/net/wireless/rt2x00/rt2500usb.h            |   10 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |  145 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |   11 +-
 drivers/net/wireless/rt2x00/rt2x00crypto.c         |   15 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c          |    6 +-
 drivers/net/wireless/rt2x00/rt2x00debug.h          |    2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |  409 +--
 drivers/net/wireless/rt2x00/rt2x00dump.h           |    2 +-
 drivers/net/wireless/rt2x00/rt2x00firmware.c       |    2 +-
 drivers/net/wireless/rt2x00/rt2x00leds.c           |    2 +-
 drivers/net/wireless/rt2x00/rt2x00leds.h           |    2 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h            |   93 +-
 drivers/net/wireless/rt2x00/rt2x00link.c           |  461 +++
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   71 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00pci.h            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |  197 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |   17 +-
 drivers/net/wireless/rt2x00/rt2x00reg.h            |   12 +-
 drivers/net/wireless/rt2x00/rt2x00rfkill.c         |  127 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h            |    2 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |  185 +-
 drivers/net/wireless/rt2x00/rt61pci.h              |    9 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |  175 +-
 drivers/net/wireless/rt2x00/rt73usb.h              |   15 +-
 drivers/net/wireless/rtl818x/rtl8187.h             |    4 +-
 drivers/net/wireless/rtl818x/rtl8187_dev.c         |   92 +-
 drivers/net/wireless/wl3501_cs.c                   |    9 +-
 drivers/net/wireless/zd1201.c                      |    7 +-
 drivers/ssb/b43_pci_bridge.c                       |    2 +
 drivers/ssb/pci.c                                  |   74 +-
 include/linux/ath9k_platform.h                     |   28 +
 include/linux/ieee80211.h                          |  181 +
 include/linux/nl80211.h                            |   36 +-
 include/linux/pci_ids.h                            |    4 +
 include/linux/spi/libertas_spi.h                   |   25 +
 include/linux/ssb/ssb_regs.h                       |   36 +
 include/linux/wireless.h                           |   12 +-
 include/net/cfg80211.h                             |   84 +
 include/net/mac80211.h                             |  212 +-
 include/net/wireless.h                             |   68 +-
 net/mac80211/Makefile                              |    3 +
 net/mac80211/aes_cmac.c                            |  135 +
 net/mac80211/aes_cmac.h                            |   19 +
 net/mac80211/cfg.c                                 |  139 +-
 net/mac80211/debugfs.c                             |   59 +-
 net/mac80211/debugfs_key.c                         |   79 +-
 net/mac80211/debugfs_key.h                         |   10 +
 net/mac80211/debugfs_sta.c                         |    5 +-
 net/mac80211/ht.c                                  |   21 +-
 net/mac80211/ieee80211_i.h                         |   68 +-
 net/mac80211/iface.c                               |   45 +-
 net/mac80211/key.c                                 |  113 +-
 net/mac80211/key.h                                 |   16 +
 net/mac80211/main.c                                |   73 +-
 net/mac80211/mesh.c                                |    5 +-
 net/mac80211/mesh.h                                |    9 +-
 net/mac80211/mesh_hwmp.c                           |    6 +-
 net/mac80211/mesh_plink.c                          |   38 +-
 net/mac80211/mlme.c                                |  267 +-
 net/mac80211/pm.c                                  |  117 +
 net/mac80211/rx.c                                  |  298 ++-
 net/mac80211/scan.c                                |   26 +-
 net/mac80211/spectmgmt.c                           |  100 +-
 net/mac80211/sta_info.h                            |    4 +-
 net/mac80211/tx.c                                  |   64 +-
 net/mac80211/util.c                                |   29 +-
 net/mac80211/wext.c                                |  148 +-
 net/mac80211/wpa.c                                 |  152 +-
 net/mac80211/wpa.h                                 |    5 +
 net/wireless/core.c                                |   12 +-
 net/wireless/nl80211.c                             |   81 +-
 net/wireless/reg.c                                 |  285 +-
 net/wireless/reg.h                                 |    7 -
 net/wireless/sysfs.c                               |   30 +
 net/wireless/util.c                                |    2 +-
 212 files changed, 16943 insertions(+), 16506 deletions(-)
 create mode 100644 drivers/net/wireless/ath9k/ahb.c
 create mode 100644 drivers/net/wireless/ath9k/pci.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-100.c
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-3945-commands.h
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-3945-debug.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-3945-fh.h
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-3945-io.h
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-3945-rs.h
 rename drivers/net/wireless/iwlwifi/{iwl-3945-core.h => iwl-6000-hw.h} (64%)
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-6000.c
 create mode 100644 drivers/net/wireless/libertas/if_spi.c
 create mode 100644 drivers/net/wireless/libertas/if_spi.h
 create mode 100644 drivers/net/wireless/orinoco/Kconfig
 create mode 100644 drivers/net/wireless/p54/p54spi.c
 create mode 100644 drivers/net/wireless/p54/p54spi.h
 create mode 100644 drivers/net/wireless/p54/p54spi_eeprom.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00link.c
 create mode 100644 include/linux/ath9k_platform.h
 create mode 100644 include/linux/spi/libertas_spi.h
 create mode 100644 net/mac80211/aes_cmac.c
 create mode 100644 net/mac80211/aes_cmac.h
 create mode 100644 net/mac80211/pm.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2009-02-03.patch.bz2
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
