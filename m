From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2016-04-11
Date: Mon, 11 Apr 2016 15:48:48 +0300
Message-ID: <87vb3o5n0v.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:34305 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754384AbcDKMs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 08:48:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here's a pull request for 4.7. More features, but nothing really
standing out. Please let me know if you have any problems.

Kalle


The following changes since commit 4da46cebbd3b4dc445195a9672c99c1353af5695:

  net/core/dev: Warn on a too-short GRO frame (2016-04-05 19:58:39 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2016-04-11

for you to fetch changes up to 20ac1b325d8d526211b1276ecf9b64b7e8369f50:

  Merge ath-next from ath.git (2016-04-07 21:44:37 +0300)

----------------------------------------------------------------

wireless-drivers patches for 4.7

Major changes:

iwlwifi

* support for Link Quality measurement
* more work 9000 devices and MSIx
* continuation of the Dynamic Queue Allocation work
* make the paging less memory hungry
* 9000 new Rx path
* removal of IWLWIFI_UAPSD Kconfig option

ath10k

* implement push-pull tx model using mac80211 software queuing support
* enable scan in AP mode (NL80211_FEATURE_AP_SCAN)

wil6210

* add basic PBSS (Personal Basic Service Set) support
* add initial P2P support
* add oob_mode module parameter

----------------------------------------------------------------
Amitkumar Karwar (2):
      mwifiex: fix Tx timeout issue during suspend test
      mwifiex: advertise low priority scan feature

Anilkumar Kolli (1):
      ath10k: fix debugfs pktlog_filter write

Aviya Erenfeld (2):
      iwlwifi: mvm: add LQM vendor command and notification
      iwlwifi: add a debugfs hook for LQM

Ayala Beker (1):
      iwlwifi: mvm: update GSCAN capabilities

Bob Copeland (3):
      ath5k: fix incorrect indentation
      ath9k: fix a misleading indentation
      ath9k_htc: fix up indents with spaces

Chaya Rachel Ivgi (2):
      iwlwifi: mvm: handle async temperature notification with unlocked mutex
      iwlwifi: mvm: remove uneeded D0I3 checking

Colin Ian King (4):
      iwlwifi: pcie: remove duplicate assignment of variable isr_stats
      wl12xx: remove redundant null check on wl->scan.ssid
      brcmfmac: sdio: remove unused variable retry_limit
      mwifiex: ie_list is an array, so no need to check if NULL

Dan Carpenter (1):
      brcmfmac: uninitialized "ret" variable

David Spinadel (1):
      iwlwifi: mvm: set aux STA ID in scan config

Dedy Lansky (1):
      wil6210: p2p initial support

Emmanuel Grumbach (6):
      iwlwifi: pcie: print error value as signed int
      iwlwifi: mvm: modify the max SP to infinite
      iwlwifi: add missing mutex_destroy statements
      iwlwifi: make uapsd_disable module param a bitmap
      iwlwifi: remove IWLWIFI_UAPSD Kconfig
      iwlwifi: remove IWL_*_UCODE_API_OK

Eva Rachel Retuya (1):
      iwlwifi: dvm: use alloc_ordered_workqueue()

Ganapathi Bhat (2):
      mwifiex: add support for GTK rekey offload
      mwifiex: add support for wakeup on GTK rekey failure

Geert Uytterhoeven (1):
      mwifiex: Spelling s/minmum/minimum/, s/bandwidth/bandwith/

Geliang Tang (4):
      ipw2x00: use to_pci_dev()
      wlcore: use to_delayed_work()
      wl1251: use to_delayed_work()
      rtlwifi: use to_delayed_work()

Golan Ben-Ami (2):
      iwlwifi: mvm: support dumping UMAC internal txfifos
      iwlwifi: store fw memory segments length and addresses in run-time

Grzegorz Bajorski (1):
      ath10k: deliver mgmt frames from htt to monitor vifs only

Haim Dreyfuss (2):
      iwlwifi: 9000: update device id and FW serial number
      iwlwifi: pcie: Fix index iteration on free_irq in MSIX mode

Hamad Kadmany (1):
      wil6210: Set permanent MAC address to wiphy

Ivan Safonov (1):
      ath9k: Remove unnecessary ?: operator

Jes Sorensen (10):
      rtl8xxxu: Change name of struct tx_desc to be more decriptive
      rtl8xxxu: Rename TX descriptor bits to map them to 32/40 byte descriptors
      rtl8xxxu: Correct txdesc40 gid definition
      rtl8xxxu: TXDESC_SHORT_GI is txdesc32 only
      rtl8xxxu: 8192eu uses txdesc40
      rtl8xxxu: Update some register definitions
      rtl8xxxu: Use enums for chip version numbers
      rtl8xxxu: Identify 8192eu rev A/B parts correctly
      rtl8xxxu: Use correct H2C calls for 8192eu
      rtl8xxxu: Do not set LDOA15 / LDOV12 on 8192eu

Jia-Ju Bai (4):
      iwl4965: Fix a null pointer dereference in il_tx_queue_free and il_cmd_queue_free
      b43: Fix memory leaks in b43_bus_dev_ssb_init and b43_bus_dev_bcma_init
      rtl818x_pci: Disable pci device in error handling code
      iwl4965: Fix a memory leak in error handling code of __il4965_up

Joe Perches (1):
      rtlwifi: btcoexist: Convert BTC_PRINTK to btc_<foo>_dbg

Johannes Berg (1):
      iwlwifi: mvm: remove is_data_qos variable in TX

Joseph Salisbury (1):
      ath5k: Change led pin configuration for compaq c700 laptop

Julian Calaby (1):
      iwl4965: Fix more memory leaks in __il4965_up()

Kalle Valo (2):
      Merge tag 'iwlwifi-next-for-kalle-2016-03-30' of https://git.kernel.org/.../iwlwifi/iwlwifi-next
      Merge ath-next from ath.git

Larry Finger (11):
      rtlwifi: rtl8723be: Add antenna select module parameter
      rtlwifi: btcoexist: Implement antenna selection
      rtlwifi: Fix Smatch warnings
      rtlwifi: btcoexist: Fix Smatch warning
      rtlwifi: rtl8188ee: Fix Smatch warnings
      rtlwifi: rtl8192c-common: Fix Smatch warning
      rtlwifi: rtl8192ee: Fix Smatch warning
      rtlwifi: rtl8192se: Fix Smatch warning
      rtlwifi: rtl8723ae: Fix Smatch warning
      rtlwifi: rtl8723be: Fix Smatch warnings
      rtlwifi: rtl8821ae: Fix Smatch warnings

Liad Kaufman (7):
      iwlwifi: mvm: support bss dynamic alloc/dealloc of queues
      iwlwifi: trans: fix iwl_trans_txq_scd_cfg.sta_id sign
      iwlwifi: mvm: use bss client queue for bss station
      iwlwifi: mvm: set sta_id in SCD_QUEUE_CONFIG cmd
      iwlwifi: mvm: allocate dedicated queue for cab in dqa mode
      iwlwifi: mvm: move cmd queue to be #0 in dqa mode
      iwlwifi: mvm: fix inconsistent lock in dqa mode

Lior David (10):
      wil6210: add support for discovery mode during scan
      wil6210: switch to generated wmi.h
      wil6210: basic PBSS/PCP support
      wil6210: P2P_DEVICE virtual interface support
      wil6210: fix race conditions in p2p listen and search
      wil6210: clean ioctl debug message
      wil6210: fix no_fw_recovery mode with change_virtual_intf
      wil6210: pass is_go flag to firmware
      wil6210: add oob_mode module parameter
      wil6210: allow empty WMI commands in debugfs wmi_send

Luca Coelho (3):
      iwlwifi: pcie: refcounting is not necessary anymore
      iwlwifi: mvm: add a scan timeout for regular scans
      iwlwifi: mvm: allow setting the thermal state in D0i3

Markus Elfring (6):
      ath9k_htc: Delete unnecessary variable initialisation
      brcmfmac: Delete unnecessary variable initialisation
      iwlegacy: Return directly if allocation fails in il_eeprom_init()
      rsi: Delete unnecessary variable initialisation
      rsi: Delete unnecessary variable initialisation
      rsi: Move variable initialisation into error code

Matti Gottlieb (2):
      iwlwifi: mvm: Decrease size of the paging download buffer
      iwlwifi: mvm: make sure FW contains the right amount of paging sections

Maya Erez (3):
      wil6210: remove BACK RX and TX workers
      wil6210: AP: prevent connecting to already connected station
      wil6210: add support for platform specific notification events

Miaoqing Pan (23):
      ath9k: Update QCA953x initvals
      ath9k: Update AR9003 2.2 initvals
      ath9k: Update AR933x initvals
      ath9k: Update AR9340 initvals
      ath9k: Update AR9462 initvals
      ath9k: Update AR9485 initvals
      ath9k: Update AR955x initvals
      ath9k: Update AR9565 initvals
      ath9k: Update QCA956x initvals
      ath9k: Update AR9580 initvals
      ath9k: enable manual peak cal for all ar9300 chips
      ath9k: use AR_SREV_9003_PCOEM to identify PCOEM chips
      ath9k: set correct peak detect threshold
      ath9k: define correct GPIO numbers and bits mask
      ath9k: make GPIO API to support both of WMAC and SOC
      ath9k: free GPIO resource for SOC GPIOs
      ath9k: cleanup led_pin initial
      ath9k: Allow platform override BTCoex pin
      ath9k: add bits definition of BTCoex MODE2/3 for SOC chips
      ath9k: fix BTCoex access invalid registers for SOC chips
      ath9k: fix BTCoex configuration for SOC chips
      ath9k: fix reg dump data bus error
      ath9k: fix rng high cpu load

Michal Kazior (16):
      ath10k: refactor tx code
      ath10k: unify txpath decision
      ath10k: refactor tx pending management
      ath10k: maintain peer_id for each sta and vif
      ath10k: add fast peer_map lookup
      ath10k: add new htt message generation/parsing logic
      ath10k: implement wake_tx_queue
      ath10k: implement updating shared htt txq state
      ath10k: store txq in skb_cb
      ath10k: keep track of queue depth per txq
      ath10k: implement push-pull tx
      ath10k: fix HTT Tx CE ring size
      ath10k: change htt tx desc/qcache peer limit config
      ath10k: fix tx hang
      ath10k: fix pull-push tx threshold handling
      ath10k: fix null deref if device crashes early

Mohammed Shafi Shajakhan (2):
      ath10k: enable debugfs provision to enable Peer Stats feature
      ath10k: enable parsing per station rx duration for 10.4

Oren Givon (1):
      iwlwifi: edit the 9000 series PCI IDs

Peter Oh (2):
      ath10k: set MAC timestamp in management Rx frame
      ath10k: parse Rx MAC timestamp in mgmt frame for FW 10.4

Raja Mani (6):
      ath10k: free cached fw bin contents when get board id fails
      dt: bindings: add new dt entry for pre calibration in qcom, ath10k.txt
      ath10k: pass cal data location as an argument to ath10k_download_cal_{file|dt}
      ath10k: move cal data len to hw_params
      ath10k: incorporate qca4019 cal data download sequence
      ath10k: introduce Extended Resource Config support for 10.4

Rajkumar Manoharan (15):
      ath10k: fix firmware assert in monitor mode
      ath10k: handle channel change htt event
      ath10k: move mgmt descriptor limit handle under mgmt_tx
      ath10k: speedup htt rx descriptor processing for tx completion
      ath10k: copy tx fetch indication message
      ath10k: remove unused fw_desc processing
      ath10k: cleanup amsdu processing for rx indication
      ath10k: speedup htt rx descriptor processing for rx_ind
      ath10k: register ath10k_htt_htc_t2h_msg_handler
      ath10k: cleanup copy engine receive next completion
      ath10k: reuse copy engine 5 (htt rx) descriptors
      ath10k: combine txrx and replenish task
      ath10k: fix calibration init sequence of qca99x0
      ath10k: remove unnecessary warning for probe response drops
      ath10k: fix unconditional num_mpdus_ready subtraction

Sara Sharon (11):
      iwlwifi: pcie: clear trans reference on queue stop
      iwlwifi: pcie: fix global table size
      iwlwifi: pcie: enable interrupts explicitly on resume
      iwlwifi: pcie: do not pad QoS AMSDU
      iwlwifi: mvm: add support for new TX CMD API
      iwlwifi: pcie: write to legacy register also in MQ
      iwlwifi: remove support for fw older than -16.ucode
      iwlwifi: mvm: report checksum is done also for IPv6 packets
      iwlwifi: pcie: request one more interrupt vector
      iwlwifi: mvm: improve RSS configuration
      iwlwifi: mvm: enable TCP/UDP checksum support for 9000 family

Shengzhen Li (1):
      mwifiex: check revision id while choosing PCIe firmware

Steve deRosier (1):
      ath6kl: ignore WMI_TXE_NOTIFY_EVENTID based on fw capability flags

Vasanthakumar Thiagarajan (1):
      ath10k: advertise force AP scan feature

Vishal Thanki (1):
      rt2x00usb: Use usb anchor to manage URB

Vladimir Kondratiev (1):
      wil6210: replay attack detection

Wei-Ning Huang (1):
      mwifiex: fix NULL pointer dereference error

Xinming Hu (4):
      mwifiex: remove redundant GFP_DMA flag
      mwifiex: schedule main workqueue for transmitting bridge packets
      mwifiex: AMSDU Rx frame handling in AP mode
      mwifiex: dump pcie scratch registers

 .../bindings/net/wireless/qcom,ath10k.txt          |   23 +-
 drivers/net/wireless/ath/ath10k/ce.c               |   44 +-
 drivers/net/wireless/ath/ath10k/ce.h               |   15 +-
 drivers/net/wireless/ath/ath10k/core.c             |  156 ++-
 drivers/net/wireless/ath/ath10k/core.h             |   41 +-
 drivers/net/wireless/ath/ath10k/debug.c            |  100 +-
 drivers/net/wireless/ath/ath10k/htt.c              |    2 +-
 drivers/net/wireless/ath/ath10k/htt.h              |   55 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |  714 +++++++----
 drivers/net/wireless/ath/ath10k/htt_tx.c           |  291 ++++-
 drivers/net/wireless/ath/ath10k/hw.h               |    6 +-
 drivers/net/wireless/ath/ath10k/mac.c              |  546 +++++++-
 drivers/net/wireless/ath/ath10k/mac.h              |    6 +
 drivers/net/wireless/ath/ath10k/pci.c              |  106 +-
 drivers/net/wireless/ath/ath10k/txrx.c             |   37 +-
 drivers/net/wireless/ath/ath10k/txrx.h             |    4 +-
 drivers/net/wireless/ath/ath10k/wmi-ops.h          |   23 +
 drivers/net/wireless/ath/ath10k/wmi.c              |  132 +-
 drivers/net/wireless/ath/ath10k/wmi.h              |   54 +
 drivers/net/wireless/ath/ath5k/led.c               |    2 +-
 drivers/net/wireless/ath/ath5k/phy.c               |    2 +-
 drivers/net/wireless/ath/ath5k/reset.c             |    4 +-
 drivers/net/wireless/ath/ath6kl/wmi.c              |    5 +
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   44 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   10 +-
 drivers/net/wireless/ath/ath9k/ar9003_mci.c        |   39 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   10 +-
 .../net/wireless/ath/ath9k/ar9330_1p1_initvals.h   |    4 +-
 .../net/wireless/ath/ath9k/ar9330_1p2_initvals.h   |    4 +-
 drivers/net/wireless/ath/ath9k/ar9340_initvals.h   |    4 +-
 .../net/wireless/ath/ath9k/ar9462_2p0_initvals.h   |    4 +-
 .../net/wireless/ath/ath9k/ar9462_2p1_initvals.h   |    4 +-
 drivers/net/wireless/ath/ath9k/ar9485_initvals.h   |    4 +-
 drivers/net/wireless/ath/ath9k/ar953x_initvals.h   |    4 +-
 .../net/wireless/ath/ath9k/ar955x_1p0_initvals.h   |    2 +-
 .../net/wireless/ath/ath9k/ar9565_1p0_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ar956x_initvals.h   |    2 +-
 .../net/wireless/ath/ath9k/ar9580_1p0_initvals.h   |    4 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    4 -
 drivers/net/wireless/ath/ath9k/btcoex.c            |  138 +-
 drivers/net/wireless/ath/ath9k/btcoex.h            |    2 +
 drivers/net/wireless/ath/ath9k/debug.c             |   24 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |   69 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c           |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c      |    8 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   14 +-
 drivers/net/wireless/ath/ath9k/hw.c                |  267 ++--
 drivers/net/wireless/ath/ath9k/hw.h                |   11 +-
 drivers/net/wireless/ath/ath9k/init.c              |    1 -
 drivers/net/wireless/ath/ath9k/main.c              |    9 +-
 drivers/net/wireless/ath/ath9k/reg.h               |   90 +-
 drivers/net/wireless/ath/ath9k/rng.c               |   20 +-
 drivers/net/wireless/ath/wil6210/Makefile          |    1 +
 drivers/net/wireless/ath/wil6210/cfg80211.c        |  332 ++++-
 drivers/net/wireless/ath/wil6210/debugfs.c         |   59 +-
 drivers/net/wireless/ath/wil6210/interrupt.c       |    6 +-
 drivers/net/wireless/ath/wil6210/ioctl.c           |   11 +-
 drivers/net/wireless/ath/wil6210/main.c            |   81 +-
 drivers/net/wireless/ath/wil6210/netdev.c          |    7 +-
 drivers/net/wireless/ath/wil6210/p2p.c             |  253 ++++
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |    1 +
 drivers/net/wireless/ath/wil6210/rx_reorder.c      |  204 +--
 drivers/net/wireless/ath/wil6210/trace.h           |   19 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |   67 +-
 drivers/net/wireless/ath/wil6210/txrx.h            |   12 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |  110 +-
 drivers/net/wireless/ath/wil6210/wil_platform.h    |    8 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |  134 +-
 drivers/net/wireless/ath/wil6210/wmi.h             | 1264 +++++++++----------
 drivers/net/wireless/broadcom/b43/main.c           |    6 +-
 .../wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c  |    2 +-
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |    5 +-
 drivers/net/wireless/intel/ipw2x00/ipw2100.c       |    2 +-
 drivers/net/wireless/intel/iwlegacy/4965-mac.c     |    3 +
 drivers/net/wireless/intel/iwlegacy/common.c       |   22 +-
 drivers/net/wireless/intel/iwlwifi/Kconfig         |   10 -
 drivers/net/wireless/intel/iwlwifi/dvm/main.c      |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-1000.c      |   10 +-
 drivers/net/wireless/intel/iwlwifi/iwl-2000.c      |   18 +-
 drivers/net/wireless/intel/iwlwifi/iwl-5000.c      |   11 +-
 drivers/net/wireless/intel/iwlwifi/iwl-6000.c      |   20 +-
 drivers/net/wireless/intel/iwlwifi/iwl-7000.c      |   26 +-
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c      |   13 +-
 drivers/net/wireless/intel/iwlwifi/iwl-9000.c      |   17 +-
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |    7 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c       |  100 +-
 .../net/wireless/intel/iwlwifi/iwl-fw-error-dump.h |    1 +
 drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h   |   41 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fw.h        |    2 +
 drivers/net/wireless/intel/iwlwifi/iwl-modparams.h |   10 +-
 drivers/net/wireless/intel/iwlwifi/iwl-prph.h      |   12 +
 drivers/net/wireless/intel/iwlwifi/iwl-trans.h     |    4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/Makefile    |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/coex.c      |   42 -
 .../net/wireless/intel/iwlwifi/mvm/coex_legacy.c   | 1315 --------------------
 drivers/net/wireless/intel/iwlwifi/mvm/constants.h |    1 -
 drivers/net/wireless/intel/iwlwifi/mvm/d3.c        |    2 +-
 .../net/wireless/intel/iwlwifi/mvm/debugfs-vif.c   |   85 ++
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c   |  169 +--
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rx.h |   15 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-tx.h |   35 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h    |  108 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c    |  140 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        |   54 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |   47 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |   75 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |   47 +-
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |   34 +-
 drivers/net/wireless/intel/iwlwifi/mvm/power.c     |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |    9 +-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |   22 +
 drivers/net/wireless/intel/iwlwifi/mvm/sf.c        |    8 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |  262 +++-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |   87 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c        |   15 -
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |  192 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c     |  161 ++-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |   16 +-
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |    6 +-
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c       |   12 +-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |   35 +-
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c       |   80 +-
 .../net/wireless/marvell/mwifiex/11n_rxreorder.c   |    5 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |   29 +-
 drivers/net/wireless/marvell/mwifiex/fw.h          |   11 +
 drivers/net/wireless/marvell/mwifiex/main.c        |    8 +-
 drivers/net/wireless/marvell/mwifiex/main.h        |    2 +
 drivers/net/wireless/marvell/mwifiex/pcie.c        |   98 +-
 drivers/net/wireless/marvell/mwifiex/pcie.h        |   18 +-
 drivers/net/wireless/marvell/mwifiex/sdio.c        |    7 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmd.c     |   28 +
 drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c |    2 +
 drivers/net/wireless/marvell/mwifiex/sta_event.c   |    3 +
 drivers/net/wireless/marvell/mwifiex/sta_ioctl.c   |    3 +-
 drivers/net/wireless/marvell/mwifiex/tdls.c        |    2 +-
 drivers/net/wireless/marvell/mwifiex/uap_cmd.c     |    2 +-
 drivers/net/wireless/marvell/mwifiex/uap_txrx.c    |   92 ++
 drivers/net/wireless/ralink/rt2x00/rt2x00.h        |    3 +
 drivers/net/wireless/ralink/rt2x00/rt2x00dev.c     |    3 +
 drivers/net/wireless/ralink/rt2x00/rt2x00usb.c     |   21 +-
 drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c |    4 +-
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c   |  163 ++-
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h   |  130 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_regs.h  |   31 +-
 .../realtek/rtlwifi/btcoexist/halbtc8192e2ant.c    |  847 ++++++-------
 .../realtek/rtlwifi/btcoexist/halbtc8723b1ant.c    |  611 +++++----
 .../realtek/rtlwifi/btcoexist/halbtc8723b2ant.c    |  865 ++++++-------
 .../realtek/rtlwifi/btcoexist/halbtc8821a1ant.c    |  652 +++++-----
 .../realtek/rtlwifi/btcoexist/halbtc8821a2ant.c    |  851 +++++++------
 .../realtek/rtlwifi/btcoexist/halbtcoutsrc.c       |   31 +-
 .../realtek/rtlwifi/btcoexist/halbtcoutsrc.h       |   19 +-
 .../wireless/realtek/rtlwifi/btcoexist/rtl_btc.c   |    5 +-
 drivers/net/wireless/realtek/rtlwifi/pci.c         |   39 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/dm.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/phy.c   |    3 +-
 .../wireless/realtek/rtlwifi/rtl8192c/dm_common.c  |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/trx.c   |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/phy.c   |    2 +-
 .../wireless/realtek/rtlwifi/rtl8723ae/hal_btc.c   |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/hw.c    |    5 +
 .../net/wireless/realtek/rtlwifi/rtl8723be/phy.c   |   10 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/rf.c    |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/sw.c    |    3 +
 .../net/wireless/realtek/rtlwifi/rtl8821ae/dm.c    |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/phy.c   |    6 +-
 drivers/net/wireless/realtek/rtlwifi/wifi.h        |    5 +-
 drivers/net/wireless/rsi/rsi_91x_pkt.c             |   22 +-
 drivers/net/wireless/ti/wl1251/ps.c                |    2 +-
 drivers/net/wireless/ti/wl12xx/scan.c              |    2 +-
 drivers/net/wireless/ti/wlcore/main.c              |   10 +-
 drivers/net/wireless/ti/wlcore/ps.c                |    2 +-
 drivers/net/wireless/ti/wlcore/scan.c              |    2 +-
 include/linux/ath9k_platform.h                     |    4 +
 174 files changed, 7918 insertions(+), 5930 deletions(-)
 create mode 100644 drivers/net/wireless/ath/wil6210/p2p.c
 delete mode 100644 drivers/net/wireless/intel/iwlwifi/mvm/coex_legacy.c

-- 
Kalle Valo
