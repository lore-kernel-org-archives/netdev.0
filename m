From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2015-04-01
Date: Wed, 01 Apr 2015 18:03:36 +0300
Message-ID: <87vbhfzy9j.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:55904 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbbDAPDp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 11:03:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here's a pull request for 4.1, more info in the signed tag below. Pleas=
e
let me know if you have any problems.

Kalle

The following changes since commit 719a11cdbf57b7bdd6c87ded00fd7cb36a76=
a6a3:

  vxlan: Don't set s_addr in vxlan_create_sock (2015-03-12 23:23:16 -04=
00)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-=
next.git tags/wireless-drivers-next-for-davem-2015-04-01

for you to fetch changes up to 9374e7d2fdcad3c36dafc8d3effd554bc702c4b6=
:

  rtlwifi: rtl8192cu: Add new device ID (2015-03-30 11:38:25 +0300)

----------------------------------------------------------------
Major changes:

ath9k:

* add Active Interference Cancellation, a method implemented in the HW
  to counter WLAN RX > sensitivity degradation when BT is transmitting
  at the same time. This feature is supported by cards like WB222
  based on AR9462.

iwlwifi:

* Location Aware Regulatory was added by Arik
* 8000 device family work
* update to the BT Coex firmware API

brmcfmac:

* add new BCM43455 and BCM43457 SDIO device support
* add new BCM43430 SDIO device support

wil6210:

* take care of AP bridging
* fix NAPI behavior
* found approach to achieve 4*n+2 alignment of Rx frames

rt2x00:

* add new rt2800usb device DWA 130

rtlwifi:

* add USB ID for D-Link DWA-131
* add USB ID ASUS N10 WiFi dongle

mwifiex:

* throughput enhancements

----------------------------------------------------------------
Amitkumar Karwar (1):
      mwifiex: use del_timer variant in interrupt context

Arend van Spriel (12):
      brcmfmac: remove duplication of ramsize info
      brcmfmac: always perform cores checks
      brcmfmac: rename chip download functions
      brcmfmac: assure device is ready for download after brcmf_chip_at=
tach()
      brcmfmac: extract ram size info from internal memory registers
      brcmfmac: take save&restore memory into account for SDIO shared i=
nfo
      brcmfmac: fix watchdog timer regression
      brcmfmac: avoid runtime-pm for sdio host controller
      brcmfmac: add MODULE_FIRMWARE() macros for bcm4356 PCIe device
      brcmfmac: add support for BCM43430 SDIO chipset
      brcmfmac: only support the BCM43455/7 device
      brcmfmac: remove support for unreleased BCM4354 PCIe

Arik Nemtsov (12):
      iwlwifi: mvm: add MCC update FW API
      iwlwifi: mvm: init country code on init/recovery
      iwlwifi: create regdomain from mcc_update_cmd response
      iwlwifi: mvm: consider LAR support during NVM parse
      iwlwifi: ignore IBSS flag as regulatory NO-IR indication
      iwlwifi: mvm: LAR: Add chub mcc change notify command
      iwlwifi: nvm: init correct nvm channel list for 8000 devices
      iwlwifi: allow disabling LAR via module param
      iwlwifi: use correct NVM offset for LAR enable for new NVMs
      iwlwifi: mvm: reflect TDLS pm state in mvmvif->pm_enabled
      iwlwifi: don't allow the FW to return invalid ch indices
      iwlwifi: mvm: don't init MCC during CT-kill

Avinash Patil (5):
      mwifiex: lock main process till reinitialization of vif is over
      mwifiex: rename alloc_rx_buf to alloc_dma_aligned_buf
      mwifiex: enhance SD8897 MP aggregation limits
      mwifiex: fix crash in SDIO RX path
      mwifiex: stop command path in suspend handler

Cathy Luo (1):
      mwifiex: fix a bug in Rx multiport aggregation logic

Dan Carpenter (2):
      mwifiex: missing curly braces in mwifiex_write_data_complete()
      mwifiex: remove an unneede NULL check in mwifiex_init_adapter()

Eliad Peller (3):
      iwlwifi: don't declare support for 5ghz if not supported
      iwlwifi: use IWL_DEFAULT_MAX_TX_POWER for max_eirp
      iwlwifi: disable 11ac if 11n is disabled

Emmanuel Grumbach (18):
      iwlwifi: dvm: drop VO packets when mac80211 tells us to
      iwlwifi: fix max_ht_ampdu_exponent for older devices
      iwlwifi: bump API to 13 for devices that use iwlmvm
      iwlwifi: mvm: remove IWL_UCODE_TLV_API_DISABLE_STA_TX
      iwlwifi: mvm: remove IWL_UCODE_TLV_API_SF_NO_DUMMY_NOTIF
      iwlwifi: mvm: BT Coex - disable RRC by default
      iwlwifi: mvm: always update the quota after association
      iwlwifi: pcie: speed up the Tx DMA stop flow
      iwlwifi: pcie: include more registers in the prph dump
      iwlwifi: fix smatch warning:  warn: inconsistent indenting
      iwlwifi: mvm: remove unneeded include iwl-fw-error-dump.h
      iwlwifi: mvm: fix identation
      iwlwifi: pcie: allow the op_mode to freeze the stuck queue timer
      iwlwifi: mvm: freeze the non-shared queues when a station goes to=
 sleep
      iwlwifi: mvm: fix force NMI for 8000
      iwlwifi: mvm: BT Coex - update the new API
      iwlwifi: update copyright to include 2015
      Merge branch 'iwlwifi-fixes' into iwlwifi-next

Eran Harary (5):
      iwlwifi: mvm: support new PHY_SKU nvm section for family 8000 B0
      iwlwifi: mvm: take the MAC address from HW registers
      iwlwifi: mvm: support family 8000 B2/C steps
      iwlwifi: trans: Take ownership on secure machine before FW load
      iwlwifi: mvm: Always enable the smart FIFO

Eyal Shapira (2):
      iwlwifi: mvm: rs: improve ss_params debug print
      iwlwifi: mvm: rs: update Tx statistics when using fixed rate

=46lorian Westphal (2):
      ar5523: use container_of
      ath9k: make ath_frame_info fit into reduced-size rate_driver_data

Hante Meuleman (7):
      brcmfmac: Fix oops when SDIO device is removed.
      brcmfmac: Simplify watchdog sleep.
      brcmfmac: Fix possible race-condition.
      brcmfmac: Fix race condition in msgbuf ioctl processing.
      brcmfmac: Add necessary memory barriers for SDIO.
      brcmfmac: Update msgbuf commonring size for improved throughput.
      brcmfmac: Remove unnecessary new-line in pcie console logging.

Jeff Layton (1):
      rtl8188ee: fix build break due to missing rtl_hal_pwrseqcmdparsin=
g definition

Johannes Berg (4):
      iwlwifi: mvm: disconnect if CSA time event fails scheduling
      iwlwifi: mvm: remove warning on station exhaustion
      iwlwifi: mvm: clarify time event end handling
      iwlwifi: mvm: simplify iwl_mvm_get_wakeup_status() return

Jonathan Doron (2):
      iwlwifi: mvm: support LAR updates from BIOS
      iwlwifi: mvm: set LAR MCC on D3/D0 transitions

Julia Lawall (1):
      libertas_tf: if_usb.c: don't export static symbol

Kalle Valo (1):
      Merge tag 'iwlwifi-next-for-kalle-2015-03-12' of https://git.kern=
el.org/.../iwlwifi/iwlwifi-next

Larry Finger (1):
      rtlwifi: rtl8192cu: Add new USB ID

Lars-Peter Clausen (1):
      cw1200: Fix suspend

Luciano Coelho (1):
      iwlwifi: mvm: don't double unlock the mutex in __iwl_mvm_resume()

Maithili Hinge (2):
      mwifiex: Add support for auto ARP in mwifiex.
      mwifiex: Fix issue in the SDIO reset path of mwifiex.

Marek Vasut (1):
      rtlwifi: rtl8192cu: Add new device ID

Matti Gottlieb (2):
      iwlwifi: change last 5ghz channel to 165 & add support for 8000 f=
amily
      iwlwifi: iwlmvm: LAR: disable LAR support due to NVM vs TLV confl=
ict

Nicolas Iooss (1):
      wl18xx: show rx_frames_per_rates as an array as it really is

Oleksij Rempel (18):
      ath9k_htc: add new WMI_REG_RMW_CMDID command
      ath9k: ar9271_hw_pa_cal - use defs instead of magin numbers
      ath9k: ar9271_hw_pa_cal: use proper makroses.
      ath9k: ar9271_hw_pa_cal: use RMW buffer
      ath9k: add multi_read to be compatible with ath9k_htc
      ath9k: add new function ath9k_hw_read_array
      ath9k: ar9271_hw_pa_cal: use REG_READ_ARRAY
      ath9k: use one shot read in ath9k_hw_update_mibstats
      ath9k: ath9k_hw_loadnf: use REG_RMW
      ath9k: write buffer related optimisation in ar5008_hw_set_channel=
_regs
      ath9k: ath9k_hw_set_4k_power_cal_tabl: use rmw buffer
      ath9k: use rmw buffer in ath9k_hw_set_operating_mode and ath9k_hw=
_reset
      ath9k: ath9k_hw_4k_set_board_values: use rmw buffer
      ath9k: ath9k_hw_analog_shift_rmw: use REG_RMW
      ath9k: ath9k_hw_4k_set_board_values: use rmw buffer
      ath9k: use REG_RMW and rmw buffer in ath9k_hw_4k_set_gain
      ath9k: use REG_RMW and rmw buffer in ath9k_hw_4k_set_board_values
      ath9k: use REG_RMW and rmw buffer in ath9k_hw_def_set_gain

Oren Givon (2):
      iwlwifi: add new 8260 series PCI IDs
      iwlwifi: add more new 8260 series PCI IDs

Priit Laes (2):
      rtlwifi: Clean rtl_evm_db_to_percentage a bit
      rtlwifi: No need to export rtl_evm_dbm_jaguar anymore

Rafa=C5=82 Mi=C5=82ecki (4):
      bcma: move PCI IRQ control function to host specific code
      bcma: allow disabling (not building) PCI driver
      Revert "bcma: Kconfig: Let it depend on PCI"
      bcma: gpio: use predictable base for all BCM47XX buses

Scott Branden (1):
      rt2x00: add new rt2800usb device DWA 130

Sebastian Andrzej Siewior (3):
      rt2x00usb: initialize the read value in case of failure
      rt2x00usb: check USB's request error code in rt2800usb_autorun_de=
tect()
      rt2x00usb: drop rt2x00usb_disable_radio() from rt2800usb_disable_=
radio()

Sergey Ryazanov (2):
      ath5k: channel change fix
      ath5k: fix reset race

Shengzhen Li (1):
      mwifiex: avoid queue_work while work is ongoing

Stanislaw Gruszka (1):
      rt2800usb: check Autorun mode on FW load only once

Sujith Manoharan (17):
      ath9k: Add PCIE powersave macros
      ath9k: Fix PLL powersave for AR9485
      ath9k: Initialize pll_pwrsave for AR9462/AR9565
      ath9k: Check allowed PCIE powersave configuration
      ath9k: Fix RTT chainmask usage
      ath9k: Add initial structures for AIC
      ath9k: Register private AIC ops
      ath9k: Add register definitions for AIC
      ath9k: Handle MCI_STATE_AIC_CAL_SINGLE
      ath9k: Finish AIC calibration
      ath9k: Process the AIC calibration results
      ath9k: Disable AIC by default
      ath9k: Handle MCI_STATE_AIC_CAL_RESET
      ath9k: Handle MCI_STATE_AIC_START
      ath9k: Handle MCI_STATE_AIC_CAL
      ath9k: Start AIC calibration during MCI reset
      ath9k: Fix AIC compilation error

Syed Asifful Dayyan (1):
      brcmfmac: Add support for BCM4345 SDIO chipset.

Taehee Yoo (3):
      rtlwifi: Remove duplicated prototype
      rtlwifi: rtl8192cu: remove unused arguments from _beacon_function=
_enable()
      rtlwifi: Change REG_CR+2 to MSR

Vladimir Kondratiev (10):
      wil6210: NAPI completion refactor
      wil6210: re-submit Rx frames to the wireless media if appropriate
      wil6210: support AP isolation
      wil6210: optimize index manipulation in wil_vring_reap_rx
      wil6210: fix check for FW responsiveness
      wil6210: Align Rx frames on 4*n+2 by having SNAP
      wil6210: Prefer ether_addr_copy() over memcpy()
      wil6210: add bcast structures to WMI
      wil6210: implement broadcast/multicast data
      wil6210: fall back to pseudo-DMS mcast for secure link and PBSS

Zefir Kurtisi (3):
      ath9k: restart only triggering DFS detector line
      ath9k: add DFS support for extension channel
      ath9k: allow 40MHz radar detection width

Zhaoyang Liu (6):
      mwifiex: get rid of BA setup helper functions
      mwifiex: remove_bss_prio_lock
      mwifiex: preprocess packets from TX queue
      mwifiex: add SDIO rx single port aggregation
      mwifiex: delay skb allocation for RX until cmd53 over
      mwifiex: recover from skb allocation failures during RX

 drivers/bcma/Kconfig                               |    6 +-
 drivers/bcma/bcma_private.h                        |   20 +
 drivers/bcma/driver_gpio.c                         |   23 +-
 drivers/bcma/driver_pci.c                          |   33 --
 drivers/bcma/host_pci.c                            |   34 ++
 drivers/net/wireless/ath/ar5523/ar5523.c           |    9 +-
 drivers/net/wireless/ath/ar5523/ar5523.h           |    1 -
 drivers/net/wireless/ath/ath.h                     |    3 +
 drivers/net/wireless/ath/ath5k/ath5k.h             |    1 +
 drivers/net/wireless/ath/ath5k/base.c              |   31 +-
 drivers/net/wireless/ath/ath5k/reset.c             |   24 -
 drivers/net/wireless/ath/ath9k/Makefile            |    3 +-
 drivers/net/wireless/ath/ath9k/ani.c               |   20 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |    5 +-
 drivers/net/wireless/ath/ath9k/ar9002_calib.c      |   77 ++-
 drivers/net/wireless/ath/ath9k/ar9003_aic.c        |  599 ++++++++++++=
++++++++
 drivers/net/wireless/ath/ath9k/ar9003_aic.h        |   61 ++
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |   84 ++-
 drivers/net/wireless/ath/ath9k/ar9003_mci.c        |   20 +
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |   25 -
 drivers/net/wireless/ath/ath9k/ar9003_rtt.c        |    6 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    2 +-
 drivers/net/wireless/ath/ath9k/btcoex.h            |   12 +
 drivers/net/wireless/ath/ath9k/calib.c             |   19 +-
 drivers/net/wireless/ath/ath9k/dfs.c               |   44 +-
 drivers/net/wireless/ath/ath9k/eeprom.c            |    7 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |   36 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |   34 +-
 drivers/net/wireless/ath/ath9k/htc.h               |    5 +
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |  142 ++++-
 drivers/net/wireless/ath/ath9k/hw-ops.h            |    8 +
 drivers/net/wireless/ath/ath9k/hw.c                |   37 ++
 drivers/net/wireless/ath/ath9k/hw.h                |   31 +-
 drivers/net/wireless/ath/ath9k/init.c              |   23 +-
 drivers/net/wireless/ath/ath9k/reg_aic.h           |  168 ++++++
 drivers/net/wireless/ath/ath9k/wmi.c               |    3 +
 drivers/net/wireless/ath/ath9k/wmi.h               |   16 +
 drivers/net/wireless/ath/dfs_pattern_detector.c    |    2 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |   34 +-
 drivers/net/wireless/ath/wil6210/debugfs.c         |   19 +-
 drivers/net/wireless/ath/wil6210/main.c            |   36 ++
 drivers/net/wireless/ath/wil6210/netdev.c          |    4 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |    2 -
 drivers/net/wireless/ath/wil6210/txrx.c            |  302 ++++++++--
 drivers/net/wireless/ath/wil6210/wil6210.h         |    8 +
 drivers/net/wireless/ath/wil6210/wmi.c             |   16 +-
 drivers/net/wireless/ath/wil6210/wmi.h             |   23 +-
 drivers/net/wireless/b43/main.c                    |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |    8 +-
 drivers/net/wireless/brcm80211/brcmfmac/chip.c     |  310 ++++++++--
 drivers/net/wireless/brcm80211/brcmfmac/chip.h     |   12 +-
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c   |    5 +-
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.h   |    8 +-
 drivers/net/wireless/brcm80211/brcmfmac/pcie.c     |   24 +-
 drivers/net/wireless/brcm80211/brcmfmac/sdio.c     |  199 ++++---
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |    2 +-
 .../net/wireless/brcm80211/include/brcm_hw_ids.h   |    2 +
 .../net/wireless/brcm80211/include/chipcommon.h    |    9 +-
 drivers/net/wireless/cw1200/cw1200_spi.c           |   11 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |   17 +-
 drivers/net/wireless/iwlwifi/dvm/rs.c              |    7 +-
 drivers/net/wireless/iwlwifi/dvm/tx.c              |    6 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    6 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c            |   13 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |    6 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   18 +-
 drivers/net/wireless/iwlwifi/iwl-7000.c            |    8 +-
 drivers/net/wireless/iwlwifi/iwl-8000.c            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |    2 +
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   22 +-
 drivers/net/wireless/iwlwifi/iwl-drv.h             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.h    |    1 +
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |    8 +-
 drivers/net/wireless/iwlwifi/iwl-io.c              |    2 +
 drivers/net/wireless/iwlwifi/iwl-modparams.h       |    2 +
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |  411 ++++++++++--=
--
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.h       |   19 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   27 +
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   15 +
 drivers/net/wireless/iwlwifi/mvm/coex.c            |  223 +-------
 drivers/net/wireless/iwlwifi/mvm/coex_legacy.c     |   64 ++-
 drivers/net/wireless/iwlwifi/mvm/d3.c              |   19 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |   26 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-coex.h     |   47 --
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |  107 +++-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |   10 +
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  218 ++++++-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   63 +-
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |  290 +++++++++-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |   11 +-
 drivers/net/wireless/iwlwifi/mvm/power.c           |    6 +-
 drivers/net/wireless/iwlwifi/mvm/quota.c           |    3 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |   96 +++-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |   13 +-
 drivers/net/wireless/iwlwifi/mvm/sf.c              |   67 ++-
 drivers/net/wireless/iwlwifi/mvm/sta.c             |    5 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |   31 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |    2 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |   27 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h       |    4 +
 drivers/net/wireless/iwlwifi/pcie/trans.c          |  157 ++++-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |   63 +-
 drivers/net/wireless/libertas_tf/if_usb.c          |    2 -
 drivers/net/wireless/mwifiex/11n.c                 |   18 +-
 drivers/net/wireless/mwifiex/11n.h                 |   32 --
 drivers/net/wireless/mwifiex/11n_aggr.c            |   16 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |    7 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |  167 +++++-
 drivers/net/wireless/mwifiex/decl.h                |   10 +-
 drivers/net/wireless/mwifiex/fw.h                  |   11 +
 drivers/net/wireless/mwifiex/init.c                |   26 +-
 drivers/net/wireless/mwifiex/main.c                |   76 ++-
 drivers/net/wireless/mwifiex/main.h                |   30 +-
 drivers/net/wireless/mwifiex/pcie.c                |   31 +-
 drivers/net/wireless/mwifiex/sdio.c                |  226 +++++---
 drivers/net/wireless/mwifiex/sdio.h                |   14 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |   61 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |   21 +
 drivers/net/wireless/mwifiex/sta_event.c           |    4 +-
 drivers/net/wireless/mwifiex/txrx.c                |  128 ++++-
 drivers/net/wireless/mwifiex/usb.c                 |    6 +-
 drivers/net/wireless/mwifiex/util.c                |    4 +-
 drivers/net/wireless/mwifiex/wmm.c                 |   48 +-
 drivers/net/wireless/mwifiex/wmm.h                 |    2 +
 drivers/net/wireless/rt2x00/rt2800usb.c            |   13 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h            |    4 +-
 drivers/net/wireless/rtlwifi/base.h                |    1 -
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        |    5 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |    7 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |    2 +
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ee/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c        |    4 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/trx.c       |   16 +-
 drivers/net/wireless/rtlwifi/stats.c               |   24 +-
 drivers/net/wireless/rtlwifi/stats.h               |    1 -
 drivers/net/wireless/ti/wl18xx/debugfs.c           |    2 +-
 drivers/net/wireless/ti/wlcore/debugfs.h           |    4 +-
 include/linux/bcma/bcma.h                          |    9 +
 include/linux/bcma/bcma_driver_pci.h               |    8 +-
 include/linux/mmc/sdio_ids.h                       |    2 +
 145 files changed, 4536 insertions(+), 1376 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9003_aic.c
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9003_aic.h
 create mode 100644 drivers/net/wireless/ath/ath9k/reg_aic.h

--=20
Kalle Valo
