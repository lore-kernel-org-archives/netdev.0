From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2017-02-01
Date: Wed, 01 Feb 2017 11:37:38 +0200
Message-ID: <87efzip7z1.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's a pull request to 4.11, more details in the signed tag below.

I forgot to mention in the tag that this includes one small change to
include/linux/soc/qcom/smem_state.h which was acked by Andy Gross in
commit 6c0b2e833f14. It was needed to fix a build problem with wcn36xx
using the SMD interface.

Please let me know if you have any problems.

Kalle

The following changes since commit a505e58252715bbc18a0ee1abae23615fe2586db:

  packet: pdiag_put_ring() should return TX_RING info for TPACKET_V3 (2017-=
01-10 21:02:42 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next=
.git tags/wireless-drivers-next-for-davem-2017-02-01

for you to fetch changes up to 7243a1af37a4dc9225004546d9d0756c529ad3ce:

  Merge ath-next from git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/a=
th.git (2017-01-31 09:50:50 +0200)

----------------------------------------------------------------
wireless-drivers-next patches for 4.11

It's nice to see rt2x00 development has becoming active, for example
adding support for a new chip version. Also wcn36xx has been converted
to use the recently merged QCOM_SMD subsystem. Otherwise new features
and fixes it lots of drivers.

Major changes:

iwlwifi

* some more work in preparation for A000 family support
* add support for radiotap timestamps
* some work on our firmware debugging capabilities

wcn36xx

* convert to a proper QCOM_SMD driver (from the platform_driver interface)

ath10k

* VHT160 support
* dump Copy Engine registers during firmware crash
* search board file extension from SMBIOS

wil6210

* add disable_ap_sme module parameter

rt2x00

* support RT3352 with external PA
* support for RT3352 with 20MHz crystal
* add support for RT5350 WiSoC

brcmfmac

* add support for BCM43455 sdio device

rtl8xxxu

* add support for D-Link DWA-131 rev E1, TP-Link TL-WN822N v4 and others

----------------------------------------------------------------
Amitkumar Karwar (3):
      mwifiex: use module_*_driver helper macros
      mwifiex: mwifiex_unmap_pci_memory() handling for sleep confirm
      mwifiex: use pci_dma_sync_single* APIs

Arend Van Spriel (4):
      brcmfmac: provide a value for struct wowlan_support::max_nd_match_sets
      brcmfmac: fix handling firmware results for wowl netdetect
      brcmfmac: allow wowlan support to be per device
      brcmfmac: add .update_connect_params() callback

Arnd Bergmann (1):
      mwifiex: fix uninitialized variable access in pcie_remove

Axel K=C3=B6llhofer (2):
      rtl8xxxu: Add USB ID for D-Link DWA-131 rev E1 (rtl8192eu)
      rtl8xxxu: Add additional USB IDs for rtl8192eu devices

Bhumika Goyal (1):
      wil6210: constify cfg80211_ops structures

Bjorn Andersson (5):
      soc: qcom: smem_state: Fix include for ERR_PTR()
      wcn36xx: Transition driver to SMD client
      wcn36xx: Implement firmware assisted scan
      wcn36xx: Implement print_reg indication
      wcn36xx: Don't use the destroyed hal_mutex

Brian Norris (5):
      mwifiex: debugfs: Fix (sometimes) off-by-1 SSID print
      mwifiex: pcie: use posted write to wake up firmware
      mwifiex: pcie: don't loop/retry interrupt status checks
      mwifiex: pcie: read FROMDEVICE DMA-able memory with READ_ONCE()
      mwifiex: don't complain about 'unknown event id: 0x63'

Christian Lamparter (2):
      ath10k: add accounting for the extended peer statistics
      ath9k: move RELAY and DEBUG_FS to ATH9K[_HTC]_DEBUGFS

Colin Ian King (1):
      ath9k: fix spelling mistake: "meaurement" -> "measurement"

Daniel Golle (2):
      rt2x00: rt2800lib: support for for RT3352 with external PA
      rt2x00: rt2800lib: add support for RT3352 with 20MHz crystal

Dedy Lansky (2):
      wil6210: add disable_ap_sme module parameter
      wil6210: support new WMI-only FW capability

Erik Stromdahl (2):
      ath10k: htc: removal of unused struct members
      ath10k: htc: simplified credit distribution

Felix Fietkau (2):
      ath5k: drop bogus warning on drv_set_key with unsupported cipher
      rt2x00: rt2800lib: fix rf id for RT3352

Ganapathi Bhat (1):
      mwifiex: move pcie_work and related variables inside card

Gavin Li (1):
      brcmfmac: fix incorrect event channel deduction

Guy Mishol (1):
      wlcore: print the sdio buffer after reading it

Hamad Kadmany (1):
      wil6210: protect against false interrupt during reset sequence

Jes Sorensen (3):
      rtl8xxxu: Mark 8192eu device 0x0bda:0x818b as tested
      rtl8xxxu: Add another 8192eu device to the USB list
      rtl8xxxu: Update author/maintainer contact info

Johannes Berg (5):
      iwlwifi: mvm: expose device timestamp in radiotap
      iwlwifi: mvm: accept arbitrary memory dump TLVs
      iwlwifi: mvm: make iwl_dump_prph() void
      iwlwifi: allow memory debug TLV to specify the memory type
      iwlwifi: mvm: properly check for transport data in dump

J=C3=BCrg Billeter (1):
      iwlwifi: fix MODULE_FIRMWARE for 6030

Kalle Valo (3):
      ath10k: refactor ath10k_peer_assoc_h_phymode()
      Merge tag 'iwlwifi-next-for-kalle-2017-01-26' of git://git.kernel.org=
/.../iwlwifi/iwlwifi-next
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git

Kirtika Ruchandani (3):
      iwlwifi: mvm: rs: Remove unused 'mvmvif'/'mvmsta' variables
      iwlwifi: mvm: rs: Remove unused 'mcs' variable
      iwlwifi: pcie: trans: Remove unused 'shift_param'

Larry Finger (7):
      rtlwifi: rtl8192de: Remove a pointless goto
      rtlwifi: Redo debugging macros RTPRINT and RT_PRINT_DATA
      rtlwifi: Convert COMP_XX entries into a proper debugging mask
      rtlwifi: Remove debugging entry in sysfs
      rtlwifi: Download firmware as bytes rather than as dwords
      rtlwifi: rtl8192cu: Calculate descriptor checksum correctly for BE
      rtlwifi: rtl8192cu: Convert driver to use common macros

Lazar Alexei (2):
      wil6210: support loading dedicated image for sparrow-plus devices
      wil6210: remove __func__ from debug printouts

Lior David (5):
      wil6210: missing reinit_completion in wmi_call
      wil6210: fix for broadcast workaround in PBSS
      wil6210: align to latest auto generated wmi.h
      wil6210: report association ID (AID) per station in debugfs
      wil6210: option to override A-BFT length in start AP/PCP

Luca Coelho (7):
      iwlwifi: mvm: don't restart HW if suspend fails with unified image
      iwlwifi: mvm: bump max API to 28
      iwlwifi: mvm: remove unused variable in iwl_mvm_handle_statistics()
      iwlwifi: dvm: make rs_tl_get_load() return void
      iwlwifi: mvm: remove unused sta_id variable in iwl_mvm_change_queue_o=
wner()
      iwlwifi: dvm: remove unused variable compiler warning in debugfs.c
      iwlwifi: mvm: mark ret as maybe_unused in iwl_dbgfs_fw_restart_write()

Mark Rutland (2):
      ath9k: ar9002_mac: kill off ACCESS_ONCE()
      ath9k: ar9003_mac: kill off ACCESS_ONCE()

Martin Blumenstingl (1):
      brcmfmac: add support for BCM43455 with modalias sdio:c00v02D0dA9BF

Maya Erez (1):
      wil6210: convert symbolic permissions to octal permissions

Michael Schenk (1):
      rtlwifi: rtl_usb: Fix for URB leaking when doing ifconfig up/down

Michal Kazior (1):
      ath10k: prevent sta pointer rcu violation

Mohammed Shafi Shajakhan (4):
      ath10k: fix wifi connectivity and warning in rx with channel 169
      ath10k: fix tx legacy rate reporting
      ath10k: fix per station tx bit rate reporting
      ath10k: dump Copy Engine registers during firmware crash

Pan Bian (1):
      libertas: fix improper return value

Rafa=C5=82 Mi=C5=82ecki (11):
      brcmfmac: avoid writing channel out of allocated array
      brcmfmac: don't preset all channels as disabled
      brcmfmac: setup wiphy bands after registering it first
      brcmfmac: make brcmf_of_probe more generic
      brcmfmac: drop unneeded function declarations from headers
      brcmfmac: move brcmf_c_set_joinpref_default declaration to common.h
      brcmfmac: drop brcmf_bus_detach and inline its code
      brcmfmac: rename brcmf_bus_start function to brcmf_bus_started
      brcmfmac: drop duplicated core selection from brcmf_pcie_attach
      bcma: use (get|put)_device when probing/removing device driver
      bcma: make OF code more generic (not platform_device specific)

Sara Sharon (10):
      iwlwifi: mvm: simplify paging allocation code
      iwlwifi: mvm: replace the number of blocks calculation
      iwlwifi: enlarge number of ucode sections
      iwlwifi: mvm: change iwl_mvm_tx_csum to return value
      iwlwifi: mvm: separate rate calculation to a new function
      iwlwifi: mvm: support version 2 of stored beacon notification
      iwlwifi: pcie: cleanup rfkill checks
      iwlwifi: mvm: use mvm_disable_queue instead of sharing logic
      iwlwifi: mvm: cleanup redundant assignment
      iwlwifi: alloc memory dynamically also for DVM

Sebastian Gottschall (1):
      ath10k: add VHT160 support

Serge Vasilugin (2):
      rt2x00: rt2800lib: correctly set HT20/HT40 filter
      rt2x00: add support for RT5350 WiSoC

Srinivas Kandagatla (3):
      ath10k: remove multiple defines of DIAG_TRANSFER_LIMIT
      ath10k: use dma_zalloc_coherent()
      ath10k: fix typo in addr calculation

Stanislaw Gruszka (12):
      rt2800usb: remove watchdog
      rt2800: increase TX timeout
      rt2x00: save conf settings before reset tuner
      rt2800: change default retry settings
      rt2800: tune TX_RTS_CFG config
      rt2800usb: mark tx failure on timeout
      rt2x00: do not flush empty queue
      rt2800: set max_psdu to 3 on usb devices
      rt2800: remove warning on bcn_num !=3D rt2x00dev->intf_beaconing
      rt2x00: add copy of clk for soc devices
      rt2x00: fix clk_get call
      rt2800: enable rt3290 unconditionally on pci probe

Waldemar Rymarkiewicz (1):
      ath10k: Search SMBIOS for OEM board file extension

Wei Yongjun (1):
      ath6kl: fix warning for using 0 as NULL

Xinming Hu (12):
      mwifiex: don't wait for main_process in shutdown_drv
      mwifiex: do not free firmware dump memory in shutdown_drv
      mwifiex: get rid of drv_info* adapter variables
      mwifiex: wait firmware dump complete during card remove process
      mwifiex: code rearrangement in pcie.c and sdio.c
      mwifiex: get rid of global user_rmmod flag
      mwifiex: get rid of mwifiex_do_flr wrapper
      mwifiex: cleanup in PCIe flr code path
      mwifiex: sdio card reset enhancement
      mwifiex: get rid of __mwifiex_sdio_remove helper
      mwifiex: get rid of global save_adapter and sdio_work
      mwifiex: remove redundant dma padding in AMSDU

 MAINTAINERS                                        |   2 +-
 drivers/bcma/main.c                                |  25 +-
 drivers/net/wireless/ath/ath10k/ce.c               |  48 +-
 drivers/net/wireless/ath/ath10k/ce.h               |   4 +-
 drivers/net/wireless/ath/ath10k/core.c             |  84 +++-
 drivers/net/wireless/ath/ath10k/core.h             |  36 ++
 drivers/net/wireless/ath/ath10k/debug.c            |  23 +-
 drivers/net/wireless/ath/ath10k/htc.c              |  35 +-
 drivers/net/wireless/ath/ath10k/htc.h              |   3 -
 drivers/net/wireless/ath/ath10k/htt_rx.c           |  11 +-
 drivers/net/wireless/ath/ath10k/hw.h               |   3 +
 drivers/net/wireless/ath/ath10k/mac.c              |  75 ++-
 drivers/net/wireless/ath/ath10k/pci.c              |   6 +-
 drivers/net/wireless/ath/ath10k/pci.h              |   5 -
 drivers/net/wireless/ath/ath10k/wmi-tlv.c          |   1 +
 drivers/net/wireless/ath/ath10k/wmi-tlv.h          |   1 +
 drivers/net/wireless/ath/ath10k/wmi.c              |  11 +-
 drivers/net/wireless/ath/ath10k/wmi.h              |  27 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |   3 +-
 drivers/net/wireless/ath/ath6kl/sdio.c             |   2 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |   9 +-
 drivers/net/wireless/ath/ath9k/Makefile            |   5 +-
 drivers/net/wireless/ath/ath9k/ar9002_mac.c        |  64 +--
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |  92 ++--
 drivers/net/wireless/ath/ath9k/common-debug.h      |  27 ++
 drivers/net/wireless/ath/ath9k/common-spectral.c   |   2 +-
 drivers/net/wireless/ath/ath9k/common-spectral.h   |  23 +
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |   2 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |   2 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |   2 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   2 +-
 drivers/net/wireless/ath/wcn36xx/Kconfig           |   2 +
 drivers/net/wireless/ath/wcn36xx/dxe.c             |  16 +-
 drivers/net/wireless/ath/wcn36xx/hal.h             |  16 +
 drivers/net/wireless/ath/wcn36xx/main.c            | 146 ++++--
 drivers/net/wireless/ath/wcn36xx/smd.c             |  69 ++-
 drivers/net/wireless/ath/wcn36xx/smd.h             |   9 +-
 drivers/net/wireless/ath/wcn36xx/txrx.c            |  19 +-
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h         |  30 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        | 174 +++++--
 drivers/net/wireless/ath/wil6210/debugfs.c         | 136 +++---
 drivers/net/wireless/ath/wil6210/ethtool.c         |  10 +-
 drivers/net/wireless/ath/wil6210/fw.c              |   7 +-
 drivers/net/wireless/ath/wil6210/fw_inc.c          |  21 +-
 drivers/net/wireless/ath/wil6210/interrupt.c       |  30 +-
 drivers/net/wireless/ath/wil6210/main.c            |  87 ++--
 drivers/net/wireless/ath/wil6210/netdev.c          |  17 +-
 drivers/net/wireless/ath/wil6210/p2p.c             |  36 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |  60 ++-
 drivers/net/wireless/ath/wil6210/pm.c              |  17 +-
 drivers/net/wireless/ath/wil6210/pmc.c             |  79 ++--
 drivers/net/wireless/ath/wil6210/rx_reorder.c      |   8 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |  75 +--
 drivers/net/wireless/ath/wil6210/wil6210.h         |  29 +-
 drivers/net/wireless/ath/wil6210/wil_crash_dump.c  |  18 +-
 drivers/net/wireless/ath/wil6210/wmi.c             | 131 ++++--
 drivers/net/wireless/ath/wil6210/wmi.h             |  67 ++-
 .../wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c  |   1 +
 .../net/wireless/broadcom/brcm80211/brcmfmac/bus.h |   6 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |  97 ++--
 .../broadcom/brcm80211/brcmfmac/cfg80211.h         |   2 -
 .../wireless/broadcom/brcm80211/brcmfmac/common.c  |  10 +-
 .../wireless/broadcom/brcm80211/brcmfmac/common.h  |   2 +
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    |  14 +-
 .../wireless/broadcom/brcm80211/brcmfmac/core.h    |   1 -
 .../net/wireless/broadcom/brcm80211/brcmfmac/of.c  |   7 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/of.h  |   6 +-
 .../wireless/broadcom/brcm80211/brcmfmac/pcie.c    |   3 +-
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |   4 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/usb.c |   2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/debugfs.c   |   2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/mac80211.c  |   2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/rs.c        |  11 +-
 drivers/net/wireless/intel/iwlwifi/dvm/ucode.c     |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-6000.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-7000.c      |   4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c      |   4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-9000.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-a000.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c       | 124 +++--
 drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h   |  24 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fw.h        |   7 +-
 drivers/net/wireless/intel/iwlwifi/mvm/d3.c        |  13 +-
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c   |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h    |   6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c    | 123 +++--
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        |  69 +--
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |   9 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |   4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c        |  10 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rx.c        |   2 -
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |  31 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        | 107 +++--
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c     |  14 +-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |  51 +--
 drivers/net/wireless/marvell/libertas/cmd.c        |   2 +-
 drivers/net/wireless/marvell/mwifiex/11n_aggr.c    |  19 +-
 drivers/net/wireless/marvell/mwifiex/debugfs.c     |   3 +-
 drivers/net/wireless/marvell/mwifiex/fw.h          |   1 +
 drivers/net/wireless/marvell/mwifiex/init.c        |  38 +-
 drivers/net/wireless/marvell/mwifiex/main.c        | 137 ++----
 drivers/net/wireless/marvell/mwifiex/main.h        |  15 +-
 drivers/net/wireless/marvell/mwifiex/pcie.c        | 332 ++++++--------
 drivers/net/wireless/marvell/mwifiex/pcie.h        |   3 +
 drivers/net/wireless/marvell/mwifiex/sdio.c        | 508 ++++++++++-------=
----
 drivers/net/wireless/marvell/mwifiex/sdio.h        |   4 +-
 drivers/net/wireless/marvell/mwifiex/sta_event.c   |   4 +
 drivers/net/wireless/marvell/mwifiex/usb.c         |  41 +-
 drivers/net/wireless/marvell/mwifiex/util.c        |  15 -
 drivers/net/wireless/ralink/rt2x00/rt2800.h        |  27 ++
 drivers/net/wireless/ralink/rt2x00/rt2800lib.c     | 278 +++++++++--
 drivers/net/wireless/ralink/rt2x00/rt2800usb.c     |  49 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00.h        |   7 +
 drivers/net/wireless/ralink/rt2x00/rt2x00config.c  |  32 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00mac.c     |   3 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00mmio.c    |   2 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00soc.c     |   4 +
 drivers/net/wireless/ralink/rt2x00/rt2x00usb.c     |   2 +-
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h   |   2 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192c.c |   2 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c |   2 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723a.c |   2 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723b.c |   2 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c  |  18 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_regs.h  |   2 +-
 drivers/net/wireless/realtek/rtlwifi/base.c        |  59 ---
 drivers/net/wireless/realtek/rtlwifi/base.h        |   1 -
 drivers/net/wireless/realtek/rtlwifi/debug.c       |  61 +--
 drivers/net/wireless/realtek/rtlwifi/debug.h       |  35 +-
 drivers/net/wireless/realtek/rtlwifi/efuse.c       |  45 ++
 drivers/net/wireless/realtek/rtlwifi/efuse.h       |   4 +
 drivers/net/wireless/realtek/rtlwifi/pci.c         |  18 -
 .../net/wireless/realtek/rtlwifi/rtl8188ee/fw.c    |  67 +--
 .../net/wireless/realtek/rtlwifi/rtl8188ee/sw.c    |  11 +-
 .../wireless/realtek/rtlwifi/rtl8192c/fw_common.c  |  70 +--
 .../net/wireless/realtek/rtlwifi/rtl8192ce/sw.c    |  11 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/sw.c    |  10 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/trx.c   |   4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/trx.h   | 272 +++++------
 .../net/wireless/realtek/rtlwifi/rtl8192de/fw.c    |  71 +--
 .../net/wireless/realtek/rtlwifi/rtl8192de/sw.c    |  11 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/fw.c    |  68 +--
 .../net/wireless/realtek/rtlwifi/rtl8192ee/sw.c    |  11 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/sw.c    |  11 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/sw.c    |  11 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/sw.c    |  11 +-
 .../realtek/rtlwifi/rtl8723com/fw_common.c         |  69 +--
 .../realtek/rtlwifi/rtl8723com/fw_common.h         |   6 -
 .../net/wireless/realtek/rtlwifi/rtl8821ae/fw.c    |  67 +--
 .../net/wireless/realtek/rtlwifi/rtl8821ae/sw.c    |  11 +-
 drivers/net/wireless/realtek/rtlwifi/usb.c         |  19 +-
 drivers/net/wireless/realtek/rtlwifi/wifi.h        |  38 +-
 drivers/net/wireless/ti/wlcore/sdio.c              |  14 +-
 include/linux/mmc/sdio_ids.h                       |   1 +
 include/linux/soc/qcom/smem_state.h                |   2 +-
 156 files changed, 2847 insertions(+), 2526 deletions(-)
