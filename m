From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers-next 2017-06-25
Date: Sun, 25 Jun 2017 20:48:36 +0300
Message-ID: <87k240rma3.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

yet another pull request to net-next for 4.13, more info in the signed
tag below. While doing a test merge on net-next I noticed git doing
quite a lot of auto-merging, maybe because of mac80211 API changes, but
luckily no conflicts. But please do let me know if you have any
problems.

Patchwork shows me that I have over 100 patches still pending for review
so quite a lot still coming towards you some time next week.

Kalle

The following changes since commit 63a2f310d040a4e42f92d60762c8965cd6f2a5ed:

  Merge tag 'wireless-drivers-next-for-davem-2017-06-12' of git://git.kerne=
l.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next (2017-06-12 10:1=
4:29 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next=
.git tags/wireless-drivers-next-for-davem-2017-06-25

for you to fetch changes up to 52f8c9380f2eb051581628782a4917f2c3f9751f:

  Merge ath-next from git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/a=
th.git (2017-06-22 16:29:52 +0300)

----------------------------------------------------------------
wireless-drivers-next patches for 4.13

New features and bug fixes to quite a few different drivers, but
nothing really special standing out.

What makes me happy that we have now more vendors actively
contributing to upstream drivers. In this pull request we have patches
from Broadcom, Intel, Qualcomm, Realtek and Redpine Signals, and I
still have patches from Marvell and Quantenna pending in patchwork. Now
that's something comparing to how things looked 11 years ago in Jeff
Garzik's "State of the Union: Wireless" email:

https://lkml.org/lkml/2006/1/5/671

Major changes:

wil6210

* add low level RF sector interface via nl80211 vendor commands

* add module parameter ftm_mode to load separate firmware for factory
  testing

* support devices with different PCIe bar size

* add support for PCIe D3hot in system suspend

* remove ioctl interface which should not be in a wireless driver

ath10k

* go back to using dma_alloc_coherent() for firmware scratch memory

* add per chain RSSI reporting

brcmfmac

* add support multi-scheduled scan

* add scheduled scan support for specified BSSIDs

* add support for brcm43430 revision 0

wlcore

* add wil1285 compatible

rsi

* add RS9113 USB support

iwlwifi

* FW API documentation improvements (for tools and htmldoc)

* continuing work for the new A000 family

* bump the maximum supported FW API to 31

* improve the differentiation between 8000, 9000 and A000 families

----------------------------------------------------------------
Adrian Chadd (1):
      ath10k: go back to using dma_alloc_coherent() for firmware scratch me=
mory

Amitkumar Karwar (1):
      rsi: use enum for FSM states

Anilkumar Kolli (1):
      ath10k: add BMI parameters to fix calibration from DT/pre-cal

Arend Van Spriel (3):
      brcmfmac: add support multi-scheduled scan
      brcmfmac: add mutex to protect pno requests
      brcmfmac: add scheduled scan support for specified BSSIDs

Ben Greear (5):
      ath10k: increase BMI timeout
      ath10k: log when longer bmi cmds happen
      ath10k: initialize nbytes to 0
      ath10k: use complete VHT chan width for 160MHz workaround
      ath10k: configure rxnss_override for QCA9984

Beni Lev (1):
      iwlwifi: mvm: add TLV for NAN API differentiation

Binoy Jayan (1):
      mwifiex: Replace semaphore async_sem with mutex

Caesar Wang (1):
      mwifiex: fixes the unexpected be printed log by default

Colin Ian King (3):
      mwifiex: make function mwifiex_ret_pkt_aggr_ctrl static
      qtnfmac: check band before allocating cmd_skb to avoid resource leak
      ath6kl: fix spelling mistake: "Indicat" -> "Indicate"

Dedy Lansky (1):
      wil6210: prevent platform callbacks after uninit

Gustavo A. R. Silva (2):
      ath10k: remove unnecessary code
      wlcore: spi: remove unnecessary variable

Haim Dreyfuss (1):
      iwlwifi: Add fw_name_pre_rf_next_step to support different rf steps

Hamad Kadmany (2):
      wil6210: add option to load FTM FW
      wil6210: Improve AP stop handling

Hans de Goede (1):
      brcmfmac: Use separate firmware for revision 0 of the brcm43430 chip

Johannes Berg (28):
      iwlwifi: mvm: fix endianness in lq_cmd declaration
      iwlwifi: mvm: document which group enums are used with which group ID
      iwlwifi: mvm: use proper sta_addr in firmware API
      iwlwifi: mvm: fix MCC endianness bug
      iwlwifi: mvm: use u8 for reserved fields
      iwlwifi: mvm: disentangle paging command structs
      iwlwifi: mvm: add documentation to some WoWLAN commands
      iwlwifi: mvm: fix some kernel-doc
      iwlwifi: mvm: add documentation links to various fields
      iwlwifi: mvm: disentangle binding command versions
      iwlwifi: mvm: create/name various enums
      iwlwifi: mvm: document structures used by commands
      iwlwifi: mvm: remove unused TX_CMD_NEXT_FRAME_*
      iwlwifi: kernel-doc: make proper links
      iwlwifi: mvm: remove unused REPLY_MAX
      iwlwifi: mvm: fix many kernel-doc warnings
      iwlwifi: mvm: document RX structures
      iwlwifi: mvm: check firmware is up in debugfs
      iwlwifi: mvm: use schedule_delayed_work()
      iwlwifi: mvm: add and use iwl_mvm_device_running()
      iwlwifi: mvm: convert ucode_loaded to a status bit
      iwlwifi: mvm: clear firmware running bit earlier
      iwlwifi: fix a kernel-doc tag
      iwlwifi: split firmware API from iwl-trans.h
      iwlwifi: mvm: link queue cmd docs to A000 command structs
      iwlwifi: mvm: document structures used for BEACON_TEMPLATE_CMD
      iwlwifi: mvm: link to TX commands in documentation
      iwlwifi: mvm: remove SCAN_GROUP

Kalle Valo (2):
      Merge tag 'iwlwifi-next-for-kalle-2017-06-06' of git://git.kernel.org=
/.../iwlwifi/iwlwifi-next
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git

Kevin Lo (1):
      rtlwifi: fix REG_USTIME_TSF register definition

Liad Kaufman (5):
      iwlwifi: mvm: remove wrt support of page dumps in gen2
      iwlwifi: pcie: support page dumping in wrt in gen2
      iwlwifi: mvm: support init flow debugging
      iwlwifi: pcie: support dumping FH in a000 hw
      iwlwifi: mvm: disable prph collection in a000 hw

Lior David (1):
      wil6210: low level RF sector API

Luca Coelho (2):
      iwlwifi: bump max FW API to 31
      iwlwifi: remove unnecessary code in iwl_trans_alloc_tx_cmd

Martin Michlmayr (1):
      brcmfmac: Fix grammar issue in error message

Maya Erez (3):
      wil6210: support devices with different PCIe bar size
      wil6210: add support for PCIe D3hot in system suspend
      wil6210: remove ioctl interface

Micha=C5=82 Miros=C5=82aw (1):
      brcmfmac: initialize oob irq data before request_irq()

Mordechai Goodstein (1):
      iwlwifi: fw-api: cleanup cycle includes

Norik Dzhandzhapanyan (1):
      ath10k: add per chain RSSI reporting

Peter S. Housel (1):
      brcmfmac: Fix glom_skb leak in brcmf_sdiod_recv_chain

Ping-Ke Shih (11):
      rtlwifi: btcoex: call bind to setup btcoex
      rtlwifi: btcoex: set correct interface type and parameter.
      rtlwifi: btcoex: rtl8723be: fix ant_sel not work
      rtlwifi: Correct power save capability while init mac80211
      rtlwifi: extend debug_comp to u64
      rtlwifi: Add TX report and disable key to force wait until report ack=
ed.
      rtlwifi: Revise special packet notification to be readable format.
      rtlwifi: Add btcoex record_pwr_mode
      rtlwifi: Add rx ampdu cfg for btcoexist.
      rtlwifi: add btc_is_bt_lps_on() for btcoexist
      rtlwifi: btcoexist control to enter/leave LPS

Prameela Rani Garnepudi (5):
      rsi: add usb RS9113 chipset support
      rsi: Register interrupt handler before firmware load
      rsi: receive path enhancement for RS9113
      rsi: configure new boot parameters to device
      rsi: add tx frame for common device configuration

Ryan Hsu (1):
      ath10k: fix the logic of limiting tdls peer counts

Sara Sharon (12):
      iwlwifi: mvm: flush per station for DQA mode
      iwlwifi: mvm: support getting nvm data from firmware
      iwlwifi: mvm: support old method of NVM parsing
      iwlwifi: mvm: wait for the flushed queue only
      iwlwifi: update device ID for a000 family
      iwlwifi: add wait for tx queue empty
      iwlwifi: mvm: add AMSDU flag to offload assist
      iwlwifi: pcie: add AMSDU to gen2
      iwlwifi: cleanup references to 8000 family in NVM code
      iwlwifi: remove references to 8000 B-step devices
      iwlwifi: add dbgc_supported to transport configuration
      iwlwifi: add 9000 and A000 device families

Sarada Prasanna Garnayak (1):
      ath10k: define structures for CE ctrl/misc register

Sebastian Reichel (1):
      wlcore: add wl1285 compatible

Shawn Lin (1):
      mwifiex: debugfs: remove redunant check of mwifiex_dfs_dir

Sven Eckelmann (2):
      ath10k: fix reported HT MCS rates with NSS > 1
      ath10k: set rxnss_override for QCA9888

Yan-Hsuan Chuang (9):
      rtlwifi: btcoex: add macros to check chip type
      rtlwifi: btcoex: rename ex_halbtc*ant to ex_btc*ant
      rtlwifi: btcoex: settings before firmware is downloaded
      rtlwifi: btcoex: hook external PnP notify by chip for wifi driver
      rtlwifi: btcoex: add settings before the hardware is ready
      rtlwifi: btcoex: hook external functions for newer chips
      rtlwifi: btcoex: bind BT coex information with wifi driver
      rtlwifi: btcoex: remove unused display functions
      rtlwifi: btcoex: let btcoex get wifi rssi and link status

 .../devicetree/bindings/net/wireless/ti,wlcore.txt |   1 +
 drivers/net/wireless/ath/ath10k/bmi.h              |   6 +-
 drivers/net/wireless/ath/ath10k/ce.c               | 168 ++--
 drivers/net/wireless/ath/ath10k/ce.h               | 132 ----
 drivers/net/wireless/ath/ath10k/core.c             |  53 +-
 drivers/net/wireless/ath/ath10k/core.h             |   1 +
 drivers/net/wireless/ath/ath10k/htt_rx.c           |  27 +-
 drivers/net/wireless/ath/ath10k/hw.c               | 137 ++++
 drivers/net/wireless/ath/ath10k/hw.h               |  87 ++
 drivers/net/wireless/ath/ath10k/mac.c              |  77 +-
 drivers/net/wireless/ath/ath10k/pci.c              |  27 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |  51 +-
 drivers/net/wireless/ath/ath10k/wmi.h              |   3 +
 drivers/net/wireless/ath/ath6kl/htc_pipe.c         |   2 +-
 drivers/net/wireless/ath/wil6210/Makefile          |   1 -
 drivers/net/wireless/ath/wil6210/cfg80211.c        | 613 +++++++++++++++
 drivers/net/wireless/ath/wil6210/debugfs.c         |  49 ++
 drivers/net/wireless/ath/wil6210/interrupt.c       |   6 +
 drivers/net/wireless/ath/wil6210/ioctl.c           | 180 -----
 drivers/net/wireless/ath/wil6210/main.c            |   7 +-
 drivers/net/wireless/ath/wil6210/netdev.c          |   8 -
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |  98 ++-
 drivers/net/wireless/ath/wil6210/pm.c              | 228 +++++-
 drivers/net/wireless/ath/wil6210/txrx.c            |  71 ++
 drivers/net/wireless/ath/wil6210/wil6210.h         |  40 +-
 drivers/net/wireless/ath/wil6210/wil_platform.h    |   7 +-
 drivers/net/wireless/ath/wil6210/wmi.c             | 147 +++-
 drivers/net/wireless/ath/wil6210/wmi.h             |  27 +-
 .../wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c  |  15 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |  69 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.h         |   6 +-
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    |   1 +
 .../wireless/broadcom/brcm80211/brcmfmac/debug.h   |   2 +
 .../broadcom/brcm80211/brcmfmac/fwil_types.h       |  43 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/pno.c | 444 +++++++++--
 .../net/wireless/broadcom/brcm80211/brcmfmac/pno.h |  47 +-
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |   7 +-
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c      |  10 +-
 drivers/net/wireless/intel/iwlwifi/iwl-9000.c      |  14 +-
 drivers/net/wireless/intel/iwlwifi/iwl-a000.c      |   8 +-
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |  11 +-
 drivers/net/wireless/intel/iwlwifi/iwl-csr.h       |   8 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c       |   6 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.h       |  12 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fh.h        |   2 +
 drivers/net/wireless/intel/iwlwifi/iwl-fw-api.h    | 205 +++++
 .../net/wireless/intel/iwlwifi/iwl-fw-error-dump.h |   8 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h   |  16 +-
 drivers/net/wireless/intel/iwlwifi/iwl-io.c        |   4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-modparams.h |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c |  95 +--
 drivers/net/wireless/intel/iwlwifi/iwl-trans.c     |   2 +
 drivers/net/wireless/intel/iwlwifi/iwl-trans.h     | 167 +---
 drivers/net/wireless/intel/iwlwifi/mvm/coex.c      |   3 +-
 drivers/net/wireless/intel/iwlwifi/mvm/constants.h |   1 +
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c   |  82 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-coex.h   |  10 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-d3.h |  29 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-mac.h    |  10 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-power.h  |  45 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rs.h |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rx.h |  88 ++-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-scan.h   |  34 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-sta.h    |  46 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-stats.h  |  29 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-tof.h    |  18 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-tx.h |  67 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h    | 555 +++++++++++--
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c    |  52 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        |  65 +-
 drivers/net/wireless/intel/iwlwifi/mvm/led.c       |   5 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |   6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |  42 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |  25 +-
 drivers/net/wireless/intel/iwlwifi/mvm/nvm.c       | 133 +++-
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |  32 +-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |   4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |  48 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |   2 +
 drivers/net/wireless/intel/iwlwifi/mvm/tdls.c      |   3 +-
 .../net/wireless/intel/iwlwifi/mvm/time-event.c    |   5 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tof.c       |   6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c        |  14 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |  27 +-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |  12 +-
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |   3 +
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    | 135 +++-
 drivers/net/wireless/intel/iwlwifi/pcie/tx-gen2.c  | 172 +++-
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c       |   5 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |   2 +-
 drivers/net/wireless/marvell/mwifiex/cfp.c         |   2 +-
 drivers/net/wireless/marvell/mwifiex/debugfs.c     |   3 +-
 drivers/net/wireless/marvell/mwifiex/main.h        |   2 +-
 drivers/net/wireless/marvell/mwifiex/scan.c        |   4 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c |   4 +-
 drivers/net/wireless/quantenna/qtnfmac/commands.c  |  12 +-
 drivers/net/wireless/realtek/rtlwifi/base.c        | 180 ++++-
 drivers/net/wireless/realtek/rtlwifi/base.h        |  14 +
 .../realtek/rtlwifi/btcoexist/halbt_precomp.h      |  22 +
 .../realtek/rtlwifi/btcoexist/halbtc8192e2ant.c    |   2 +-
 .../realtek/rtlwifi/btcoexist/halbtc8192e2ant.h    |  32 +-
 .../realtek/rtlwifi/btcoexist/halbtc8723b1ant.c    |  52 +-
 .../realtek/rtlwifi/btcoexist/halbtc8723b1ant.h    |  41 +-
 .../realtek/rtlwifi/btcoexist/halbtc8723b2ant.h    |   3 +
 .../realtek/rtlwifi/btcoexist/halbtc8821a1ant.h    |  38 +-
 .../realtek/rtlwifi/btcoexist/halbtc8821a2ant.h    |  26 +-
 .../realtek/rtlwifi/btcoexist/halbtcoutsrc.c       | 871 ++++++++++++++++-=
----
 .../realtek/rtlwifi/btcoexist/halbtcoutsrc.h       |  45 +-
 .../wireless/realtek/rtlwifi/btcoexist/rtl_btc.c   |  85 +-
 .../wireless/realtek/rtlwifi/btcoexist/rtl_btc.h   |   7 +
 drivers/net/wireless/realtek/rtlwifi/core.c        |   5 +-
 drivers/net/wireless/realtek/rtlwifi/debug.c       |   2 +-
 drivers/net/wireless/realtek/rtlwifi/debug.h       |   7 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/reg.h   |   2 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/sw.c    |   2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/reg.h   |   2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/reg.h   |   2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/fw.c    |  69 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/fw.h    |   4 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/sw.c    |   2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/trx.c   |   3 +
 .../net/wireless/realtek/rtlwifi/rtl8192ee/trx.h   |  14 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/reg.h   |   2 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/fw.c    |  70 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/fw.h    |   4 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/hw.c    |   3 +
 .../net/wireless/realtek/rtlwifi/rtl8723be/reg.h   |   2 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/trx.c   |   3 +
 .../net/wireless/realtek/rtlwifi/rtl8723be/trx.h   |  16 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/fw.c    |  72 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/fw.h    |   4 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/reg.h   |   2 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/trx.c   |   3 +
 .../net/wireless/realtek/rtlwifi/rtl8821ae/trx.h   |  17 +-
 drivers/net/wireless/realtek/rtlwifi/wifi.h        |  18 +
 drivers/net/wireless/rsi/rsi_91x_hal.c             |   4 +-
 drivers/net/wireless/rsi/rsi_91x_main.c            |   9 +-
 drivers/net/wireless/rsi/rsi_91x_mgmt.c            | 120 ++-
 drivers/net/wireless/rsi/rsi_91x_sdio.c            |  21 +-
 drivers/net/wireless/rsi/rsi_91x_usb.c             |   1 +
 drivers/net/wireless/rsi/rsi_boot_params.h         |  15 +-
 drivers/net/wireless/rsi/rsi_hal.h                 |   3 +
 drivers/net/wireless/rsi/rsi_main.h                |  28 +-
 drivers/net/wireless/rsi/rsi_mgmt.h                |  76 ++
 drivers/net/wireless/ti/wlcore/sdio.c              |   1 +
 drivers/net/wireless/ti/wlcore/spi.c               |   8 +-
 include/uapi/linux/wil6210_uapi.h                  |  87 --
 147 files changed, 5602 insertions(+), 1821 deletions(-)
 delete mode 100644 drivers/net/wireless/ath/wil6210/ioctl.c
 create mode 100644 drivers/net/wireless/intel/iwlwifi/iwl-fw-api.h
 delete mode 100644 include/uapi/linux/wil6210_uapi.h
