From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2017-08-07
Date: Mon, 07 Aug 2017 17:55:40 +0300
Message-ID: <87h8xjjukz.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's the first pull request to net-next for 4.14, more info in the
signed tag below. This time there's a simple conflict in iwlwifi but
you can fix it just like Stephen did:

https://lkml.kernel.org/r/20170804120408.0d147e86@canb.auug.org.au

Please let me know if you have any problems.

Kalle

The following changes since commit 53d56f79a0b2e4bc5bbc04988e5bfde768db604f:

  Merge branch 'qed-next' (2017-07-27 00:05:23 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2017-08-07

for you to fetch changes up to 9d546198705a79630cb29b1cc47a43e75b8afb89:

  rtlwifi: Replace hardcode value with macro (2017-08-03 13:20:43 +0300)

----------------------------------------------------------------
wireless-drivers-next patches for 4.14

The first wireless-drivers-next pull request for 4.14. I'm submitting
this unusally late in the cycle as my vacation postponed this. But
even if this is late there's not still that much new features, mostly
cleanup or fixes.

Major changes:

ath10k

* preparation for wcn3990 support

iwlwifi

* Reorganization of the code into separate directories continues

qtnfmac

* regulatory support updates

* add get_channel, dump_survey and channel_switch cfg80211 handlers

----------------------------------------------------------------
Amitkumar Karwar (5):
      rsi: use BUILD_BUG_ON check for fsm_state
      rsi: correct the logic of deriving queue number
      rsi: use macro for allocating USB buffer
      rsi: check length before USB read/write register
      rsi: fix static checker warning

Arvind Yadav (9):
      brcmfmac: constify pci_device_id
      rtlwifi: rtl8192de: constify pci_device_id.
      rtlwifi: rtl8192se: constify pci_device_id.
      rtlwifi: rtl8821ae: constify pci_device_id.
      rtlwifi: rtl8723ae: constify pci_device_id.
      rtlwifi: rtl8723be: constify pci_device_id.
      rtlwifi: rtl8188ee: constify pci_device_id.
      rtlwifi: rtl8192ee: constify pci_device_id.
      net: qtnfmac: constify pci_device_id.

Brian Norris (21):
      mwifiex: correct channel stat buffer overflows
      mwifiex: reunite copy-and-pasted remove/reset code
      mwifiex: reset interrupt status across device reset
      mwifiex: pcie: don't allow cmd buffer reuse after reset
      mwifiex: re-register wiphy across reset
      mwifiex: unregister wiphy before freeing resources
      mwifiex: don't short-circuit netdev notifiers on interface deletion
      mwifiex: fixup init_channel_scan_gap error case
      mwifiex: ensure "disable auto DS" struct is initialized
      mwifiex: fix misnomers in mwifiex_free_lock_list()
      mwifiex: make mwifiex_free_cmd_buffer() return void
      mwifiex: utilize netif_tx_{wake,stop}_all_queues()
      mwifiex: don't open-code ARRAY_SIZE()
      mwifiex: drop 'add_tail' param from mwifiex_insert_cmd_to_pending_q()
      mwifiex: pcie: remove unnecessary masks
      mwifiex: pcie: unify MSI-X / non-MSI-X interrupt process
      mwifiex: debugfs: allow card_reset() to cancel things
      mwifiex: pcie: disable device DMA before unmapping/freeing buffers
      mwifiex: pcie: remove unnecessary 'pdev' check
      mwifiex: keep mwifiex_cancel_pending_ioctl() static
      mwifiex: drop num CPU notice

Colin Ian King (5):
      rtlwifi: kfree entry until after entry->bssid has been accessed
      mwifiex: usb: fix spelling mistake: "aggreataon"-> "aggregation"
      mwifiex: fix spelling mistake: "Insuffient" -> "Insufficient"
      zd1211rw: fix spelling mistake 'hybernate' -> 'hibernate'
      wl3501_cs: fix spelling mistake: "Insupported" -> "Unsupported"

Cong Wang (1):
      wl1251: add a missing spin_lock_init()

Dan Carpenter (2):
      mwifiex: usb: unlock on error in mwifiex_usb_tx_aggr_tmo()
      rtlwifi: rtl8821ae: Fix HW_VAR_NAV_UPPER operation

Dan Williams (1):
      ipw2100: don't return positive values to PCI probe on error

Emmanuel Grumbach (3):
      iwlwifi: mvm: fix the FIFO numbers in A000 devices
      iwlwifi: pcie: fix A-MSDU on gen2 devices
      iwlwifi: mvm: don't retake the pointer to skb's CB

Florian Fainelli (1):
      bcma: gpio: Correct number of GPIOs for BCM53573

Govind Singh (2):
      ath10k: make CE layer bus agnostic
      ath10k: add copy engine register MAP for wcn3990 target

Jeffy Chen (1):
      mwifiex: uninit wakeup info in the error handling

Johannes Berg (13):
      iwlwifi: refactor out paging code
      iwlwifi: refactor shared mem parsing
      iwlwifi: track current firmware image in common code
      iwlwifi: refactor firmware debug code
      iwlwifi: reorganize firmware API
      iwlwifi: fw api: fix various kernel-doc warnings
      iwlwifi: mvm: add and use iwl_mvm_has_unified_ucode()
      iwlwifi: mvm: check family instead of new TX API for workarounds
      iwlwifi: mvm: byte-swap constant instead of variable
      iwlwifi: pcie: rename iwl_trans_check_hw_rf_kill() to pcie
      iwlwifi: mvm: require AP_LINK_PS for TVQM
      iwlwifi: mvm: simplify bufferable MMPDU check
      iwlwifi: mvm: remove non-DQA mode

Kalle Valo (3):
      ath10k: fix indenting in ath10k_wmi_update_noa()
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git
      Merge tag 'iwlwifi-next-for-kalle-2017-08-01' of git://git.kernel.org/.../iwlwifi/iwlwifi-next

Karun Eagalapati (13):
      rsi: fix sdio card reset problem
      rsi: chip reset for SDIO interface
      rsi: correct SDIO disconnect path handling
      rsi: card reset for USB interface
      rsi: USB tx headroom cleanup
      rsi: rename USB endpoint macros
      rsi: choose correct endpoint based on queue.
      rsi: set immediate wakeup bit
      rsi: rename variable in_sdio_litefi_irq
      rsi: Optimise sdio claim and release host
      rsi: SDIO Rx packet processing enhancement
      rsi: use separate mutex lock for receive thread
      rsi: Rename mutex tx_rxlock to the tx_lock.

Liad Kaufman (1):
      iwlwifi: mvm: support fw reading empty OTP

Luca Coelho (2):
      iwlwifi: mvm: refactor beacon template command code
      iwlwifi: mvm: rename p2p-specific sta functions to include p2p in the names

Malcolm Priestley (1):
      rtlwifi: rtl_pci_probe: Fix fail path of _rtl_pci_find_adapter

Mordechai Goodstein (1):
      iwlwifi: implement fseq version mismatch warning

Pavani Muthyala (4):
      rsi: management frame descriptor preparation cleanup
      rsi: data packet descriptor code cleanup
      rsi: data packet descriptor enhancements
      rsi: separate function for data packet descriptor

Ping-Ke Shih (8):
      rtlwifi: Fill in_4way field by driver
      rtlwifi: Add BT_MP_INFO to c2h handler.
      rtlwifi: Add board type for 8723be and 8192ee
      rtlwifi: add amplifier type for 8812ae
      rtlwifi: Update 8723be new phy parameters and its parser.
      rtlwifi: Rename rtl_desc92_rate to rtl_desc_rate
      rtlwifi: Uses addr1 instead DA to determine broadcast and multicast addr.
      rtlwifi: move IS_HARDWARE_TYPE_xxx checker to wifi.h

Prameela Rani Garnepudi (19):
      rsi: changes in eeprom read frame
      rsi: separate function for management packet descriptor
      rsi: add common structures needed for command packets
      rsi: immediate wakeup bit and priority for TX command packets
      rsi: Update in tx command frame radio capabilities
      rsi: remove unnecessary check for 802.11 management packet
      rsi: Update peer notify command frame
      rsi: Update aggregation parameters command frame
      rsi: Update baseband RF programming frame
      rsi: update set_channel command frame
      rsi: update vap capabilities command frame
      rsi: update set_key command frame
      rsi: set_key enhancements
      rsi: update autorate request command frame
      rsi: block/unblock data queues as per connection status
      rsi: update tx command frame block/unblock data
      rsi: Remove internal header from Tx status skb
      rsi: Send rx filter frame to device when interface is down
      rsi: regulatory enhancements

Robin Murphy (1):
      qtnfmac: Tidy up DMA mask setting

Seraphime Kirkovski (1):
      iwlwifi: dvm: remove unused defines

Sergey Matyukevich (12):
      qtnfmac: updates for regulatory support
      qtnfmac: regulatory configuration for self-managed setup
      qtnfmac: add missing bus lock
      qtnfmac: implement cfg80211 dump_survey handler
      qtnfmac: implement reporting current channel
      qtnfmac: fix station leave reason endianness
      qtnfmac: move current channel info from vif to mac
      qtnfmac: implement cfg80211 channel_switch handler
      qtnfmac: implement scan timeout
      qtnfmac: fix handling of iftype mask reported by firmware
      qtnfmac: remove function qtnf_cmd_skb_put_action
      qtnfmac: prepare for AP_VLAN interface type support

Sharon Dvir (1):
      iwlwifi: mvm: fix uninitialized var while waiting for queues to empty

Shawn Lin (1):
      mwifiex: fix compile warning of unused variable

Souptick Joarder (4):
      rtlwifi: remove dummy function call
      rtlwifi: Remove unused dummy function
      rtlwifi: Fix memory leak when firmware request fails
      rtlwifi: Replace hardcode value with macro

Stefano Brivio (1):
      hostap: Fix outdated comment about dev->destructor

Sven Joachim (1):
      rtlwifi: Fix fallback firmware loading

Tamizh chelvam (1):
      ath10k: increase buffer len to print all wmi services

Xinming Hu (4):
      mwifiex: disable uapsd in tdls config
      mwifiex: correct IE parse during association
      mwifiex: make addba request command clean
      mwifiex: pcie: compatible with wifi-only image while extract wifi-part fw

Zamir, Roee (1):
      iwlwifi: mvm: add compile-time option to disable EBS

 drivers/bcma/driver_gpio.c                         |    1 +
 drivers/net/wireless/ath/ath10k/ahb.c              |    3 +-
 drivers/net/wireless/ath/ath10k/ce.c               |  299 +-
 drivers/net/wireless/ath/ath10k/ce.h               |   30 +-
 drivers/net/wireless/ath/ath10k/core.c             |    5 +
 drivers/net/wireless/ath/ath10k/core.h             |    2 +
 drivers/net/wireless/ath/ath10k/debug.c            |    2 +-
 drivers/net/wireless/ath/ath10k/hw.c               |  150 ++
 drivers/net/wireless/ath/ath10k/hw.h               |    9 +
 drivers/net/wireless/ath/ath10k/pci.c              |   55 +-
 drivers/net/wireless/ath/ath10k/pci.h              |   14 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |    2 +-
 .../wireless/broadcom/brcm80211/brcmfmac/pcie.c    |    2 +-
 drivers/net/wireless/intel/ipw2x00/ipw2100.c       |   28 +-
 drivers/net/wireless/intel/iwlwifi/Makefile        |    2 +
 drivers/net/wireless/intel/iwlwifi/dvm/commands.h  |   16 -
 drivers/net/wireless/intel/iwlwifi/fw/api/alive.h  |  206 ++
 .../net/wireless/intel/iwlwifi/fw/api/binding.h    |  144 +
 .../intel/iwlwifi/fw/{api.h => api/cmdhdr.h}       |   78 +-
 .../iwlwifi/{mvm/fw-api-coex.h => fw/api/coex.h}   |   11 +-
 .../net/wireless/intel/iwlwifi/fw/api/commands.h   |  664 +++++
 drivers/net/wireless/intel/iwlwifi/fw/api/config.h |  192 ++
 .../net/wireless/intel/iwlwifi/fw/api/context.h    |   94 +
 .../intel/iwlwifi/{mvm/fw-api-d3.h => fw/api/d3.h} |   11 +-
 .../net/wireless/intel/iwlwifi/fw/api/datapath.h   |  127 +
 drivers/net/wireless/intel/iwlwifi/fw/api/debug.h  |  345 +++
 drivers/net/wireless/intel/iwlwifi/fw/api/filter.h |  183 ++
 .../net/wireless/intel/iwlwifi/fw/api/mac-cfg.h    |  152 ++
 .../iwlwifi/{mvm/fw-api-mac.h => fw/api/mac.h}     |   33 +-
 .../net/wireless/intel/iwlwifi/fw/api/nvm-reg.h    |  386 +++
 .../net/wireless/intel/iwlwifi/fw/api/offload.h    |  101 +
 drivers/net/wireless/intel/iwlwifi/fw/api/paging.h |  108 +
 .../net/wireless/intel/iwlwifi/fw/api/phy-ctxt.h   |  164 ++
 drivers/net/wireless/intel/iwlwifi/fw/api/phy.h    |  258 ++
 .../iwlwifi/{mvm/fw-api-power.h => fw/api/power.h} |   13 +-
 .../intel/iwlwifi/{mvm/fw-api-rs.h => fw/api/rs.h} |   13 +-
 .../intel/iwlwifi/{mvm/fw-api-rx.h => fw/api/rx.h} |   31 +-
 .../iwlwifi/{mvm/fw-api-scan.h => fw/api/scan.h}   |   11 +-
 drivers/net/wireless/intel/iwlwifi/fw/api/sf.h     |  138 +
 .../iwlwifi/{mvm/fw-api-sta.h => fw/api/sta.h}     |   15 +-
 .../iwlwifi/{mvm/fw-api-stats.h => fw/api/stats.h} |   13 +-
 drivers/net/wireless/intel/iwlwifi/fw/api/tdls.h   |  208 ++
 .../net/wireless/intel/iwlwifi/fw/api/time-event.h |  386 +++
 .../iwlwifi/{mvm/fw-api-tof.h => fw/api/tof.h}     |    9 +-
 .../intel/iwlwifi/{mvm/fw-api-tx.h => fw/api/tx.h} |   42 +-
 drivers/net/wireless/intel/iwlwifi/fw/api/txq.h    |  163 ++
 drivers/net/wireless/intel/iwlwifi/fw/common_rx.c  |   88 +
 .../intel/iwlwifi/{mvm/fw-dbg.c => fw/dbg.c}       |  438 +--
 .../intel/iwlwifi/{mvm/fw-dbg.h => fw/dbg.h}       |  125 +-
 drivers/net/wireless/intel/iwlwifi/fw/init.c       |   75 +
 drivers/net/wireless/intel/iwlwifi/fw/paging.c     |  414 +++
 drivers/net/wireless/intel/iwlwifi/fw/runtime.h    |  156 ++
 drivers/net/wireless/intel/iwlwifi/fw/smem.c       |  152 ++
 drivers/net/wireless/intel/iwlwifi/iwl-trans.h     |    3 +-
 drivers/net/wireless/intel/iwlwifi/mvm/Makefile    |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/coex.c      |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/constants.h |    2 +-
 .../net/wireless/intel/iwlwifi/mvm/debugfs-vif.c   |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c   |   21 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h    | 2845 +-------------------
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        |  482 +---
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |  382 +--
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |  194 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |  121 +-
 drivers/net/wireless/intel/iwlwifi/mvm/nvm.c       |    7 +-
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |  152 +-
 drivers/net/wireless/intel/iwlwifi/mvm/phy-ctxt.c  |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/power.c     |   25 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rx.c        |   11 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |    9 +-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |    4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |  452 +---
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |   18 +-
 .../net/wireless/intel/iwlwifi/mvm/time-event.c    |   20 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tof.c       |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tof.h       |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c        |    6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |  155 +-
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c     |   18 +-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |    4 +-
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |    2 +-
 .../net/wireless/intel/iwlwifi/pcie/trans-gen2.c   |    4 +-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |    8 +-
 drivers/net/wireless/intel/iwlwifi/pcie/tx-gen2.c  |    8 +-
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c       |    5 +-
 drivers/net/wireless/intersil/hostap/hostap_main.c |    4 +-
 drivers/net/wireless/marvell/mwifiex/11n.c         |    2 +
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |    6 +-
 drivers/net/wireless/marvell/mwifiex/cfp.c         |    4 +-
 drivers/net/wireless/marvell/mwifiex/cmdevt.c      |   15 +-
 drivers/net/wireless/marvell/mwifiex/debugfs.c     |    2 -
 drivers/net/wireless/marvell/mwifiex/init.c        |   32 +-
 drivers/net/wireless/marvell/mwifiex/main.c        |  133 +-
 drivers/net/wireless/marvell/mwifiex/main.h        |    7 +-
 drivers/net/wireless/marvell/mwifiex/pcie.c        |  126 +-
 drivers/net/wireless/marvell/mwifiex/scan.c        |   11 +-
 drivers/net/wireless/marvell/mwifiex/sdio.c        |    3 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmd.c     |   19 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c |    5 +-
 drivers/net/wireless/marvell/mwifiex/sta_ioctl.c   |  121 +-
 drivers/net/wireless/marvell/mwifiex/tdls.c        |    2 +-
 drivers/net/wireless/marvell/mwifiex/usb.c         |    3 +-
 drivers/net/wireless/quantenna/qtnfmac/cfg80211.c  |  315 ++-
 drivers/net/wireless/quantenna/qtnfmac/cfg80211.h  |    4 +
 drivers/net/wireless/quantenna/qtnfmac/commands.c  |  486 +++-
 drivers/net/wireless/quantenna/qtnfmac/commands.h  |    5 +
 drivers/net/wireless/quantenna/qtnfmac/core.c      |    5 +
 drivers/net/wireless/quantenna/qtnfmac/core.h      |   27 +-
 drivers/net/wireless/quantenna/qtnfmac/event.c     |   67 +-
 .../net/wireless/quantenna/qtnfmac/pearl/pcie.c    |   30 +-
 drivers/net/wireless/quantenna/qtnfmac/qlink.h     |  202 +-
 .../net/wireless/quantenna/qtnfmac/qlink_util.c    |   26 +-
 .../net/wireless/quantenna/qtnfmac/qlink_util.h    |   10 +-
 drivers/net/wireless/realtek/rtlwifi/base.c        |   22 +-
 drivers/net/wireless/realtek/rtlwifi/base.h        |    2 +
 .../realtek/rtlwifi/btcoexist/halbt_precomp.h      |   16 -
 .../realtek/rtlwifi/btcoexist/halbtcoutsrc.c       |   17 +-
 .../wireless/realtek/rtlwifi/btcoexist/rtl_btc.c   |   28 +
 .../wireless/realtek/rtlwifi/btcoexist/rtl_btc.h   |    1 +
 drivers/net/wireless/realtek/rtlwifi/core.c        |    2 +
 drivers/net/wireless/realtek/rtlwifi/pci.c         |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/sw.c    |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/sw.c    |    2 +
 .../net/wireless/realtek/rtlwifi/rtl8192cu/hw.c    |    5 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/mac.c   |    3 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/sw.c    |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/trx.c   |   12 -
 .../net/wireless/realtek/rtlwifi/rtl8192cu/trx.h   |    3 -
 .../net/wireless/realtek/rtlwifi/rtl8192de/sw.c    |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/fw.c    |    9 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/hw.c    |    5 +
 .../net/wireless/realtek/rtlwifi/rtl8192ee/sw.c    |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/sw.c    |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/sw.c    |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/fw.c    |    9 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/hw.c    |    7 +
 .../net/wireless/realtek/rtlwifi/rtl8723be/phy.c   |  365 ++-
 .../net/wireless/realtek/rtlwifi/rtl8723be/sw.c    |   17 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/table.c |  192 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/table.h |   10 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/fw.c    |   13 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/hw.c    |   43 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/sw.c    |   21 +-
 drivers/net/wireless/realtek/rtlwifi/wifi.h        |   49 +-
 drivers/net/wireless/rsi/rsi_91x_core.c            |   10 +-
 drivers/net/wireless/rsi/rsi_91x_debugfs.c         |    3 +
 drivers/net/wireless/rsi/rsi_91x_hal.c             |  270 +-
 drivers/net/wireless/rsi/rsi_91x_mac80211.c        |   63 +-
 drivers/net/wireless/rsi/rsi_91x_main.c            |    3 +-
 drivers/net/wireless/rsi/rsi_91x_mgmt.c            |  470 ++--
 drivers/net/wireless/rsi/rsi_91x_sdio.c            |  154 +-
 drivers/net/wireless/rsi/rsi_91x_sdio_ops.c        |   44 +-
 drivers/net/wireless/rsi/rsi_91x_usb.c             |  137 +-
 drivers/net/wireless/rsi/rsi_91x_usb_ops.c         |    6 +-
 drivers/net/wireless/rsi/rsi_hal.h                 |   64 +
 drivers/net/wireless/rsi/rsi_main.h                |   52 +-
 drivers/net/wireless/rsi/rsi_mgmt.h                |  171 +-
 drivers/net/wireless/rsi/rsi_sdio.h                |    4 +-
 drivers/net/wireless/rsi/rsi_usb.h                 |    6 +-
 drivers/net/wireless/ti/wl1251/main.c              |    1 +
 drivers/net/wireless/wl3501_cs.c                   |    2 +-
 drivers/net/wireless/zydas/zd1211rw/zd_rf_rf2959.c |    2 +-
 162 files changed, 9060 insertions(+), 6294 deletions(-)
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/alive.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/binding.h
 rename drivers/net/wireless/intel/iwlwifi/fw/{api.h => api/cmdhdr.h} (82%)
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-coex.h => fw/api/coex.h} (96%)
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/commands.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/config.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/context.h
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-d3.h => fw/api/d3.h} (98%)
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/datapath.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/debug.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/filter.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/mac-cfg.h
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-mac.h => fw/api/mac.h} (93%)
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/nvm-reg.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/offload.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/paging.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/phy-ctxt.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/phy.h
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-power.h => fw/api/power.h} (98%)
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-rs.h => fw/api/rs.h} (97%)
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-rx.h => fw/api/rx.h} (95%)
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-scan.h => fw/api/scan.h} (98%)
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/sf.h
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-sta.h => fw/api/sta.h} (98%)
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-stats.h => fw/api/stats.h} (97%)
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/tdls.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/time-event.h
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-tof.h => fw/api/tof.h} (98%)
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-tx.h => fw/api/tx.h} (98%)
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/txq.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/common_rx.c
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-dbg.c => fw/dbg.c} (69%)
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-dbg.h => fw/dbg.h} (59%)
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/init.c
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/paging.c
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/runtime.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/smem.c

-- 
Kalle Valo
