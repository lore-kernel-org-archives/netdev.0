From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2017-06-30
Date: Fri, 30 Jun 2017 09:19:37 +0300
Message-ID: <87fueim1za.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45456 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751918AbdF3GTq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 02:19:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here's a pull request to net-next for 4.13. Actually not really that big
this time, more info in the signed tag below. Please let me know if you
have any problems.

Intel has new hardware coming up and they just submitted patches to
iwlwifi supporting that, but because the patches were so late they
didn't make it to this one. Hence I'm planning to send you a one more
pull request on Monday(ish). I know it will be late but I'll let you
decide if you want it or not. If it doesn't fit your schedule feel free
to drop it and I'll just send it again for 4.14.

Kalle

The following changes since commit 593814d1beae8ad91be6c90f95764e09fc7ca236:

  net/mlx4: fix spelling mistake: "coalesing" -> "coalescing" (2017-06-26 23:18:29 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2017-06-30

for you to fetch changes up to fdcbe65d618af080ee23229f0137ffd37f2de36b:

  Merge ath-next from git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/ath.git (2017-06-28 22:10:48 +0300)

----------------------------------------------------------------
wireless-drivers-next patches for 4.13

Mostly fixes and cleanups, but iwlwifi and rtlwifi had also some new
features.

Major changes:

iwlwifi

* some changes in suspend/resume handling to support new FWs

* Continued work towards the A000 family

* support for a new version of the TX flush FW API

* remove some noise from the kernel logs

rtlwifi

* more bluetooth coexistance improvements

----------------------------------------------------------------
Arend Van Spriel (5):
      brcmfmac: fix double free upon register_netdevice() failure
      brcmfmac: cleanup kerneldoc for struct brcmf_bus
      brcmfmac: use atomic_t for statistic counter in struct brcmf_bus
      brcmfmac: rework headroom check in .start_xmit()
      MAINTAINERS: add brcm80211 maintainer info from Cypress

Avraham Stern (1):
      iwlwifi: mvm: set assoc_beacon_arrive_time

Bhumika Goyal (2):
      ath10k: add const to thermal_cooling_device_ops structure
      cw1200: add const to hwbus_ops structures

Chaya Rachel Ivgi (1):
      iwlwifi: mvm: fix typo in CTDP_CMD_OPERATION_REPORT description

Christophe Jaillet (1):
      brcmfmac: Fix a memory leak in error handling path in 'brcmf_cfg80211_attach'

Colin Ian King (4):
      ath10k: fix a bunch of spelling mistakes in messages
      qtnfmac: fix uninitialized return code in ret
      rsi: add in missing RSI_FSM_STATES into array fsm_state
      mwifiex: fix spelling mistake: "secuirty" -> "security"

Dan Carpenter (1):
      libertas: Fix lbs_prb_rsp_limit_set()

David Spinadel (1):
      iwlwifi: mvm: Enable security on new TX API

Emmanuel Grumbach (6):
      iwlwifi: mvm: avoid unnecessary cache trashing in Tx path
      iwlwifi: mvm: fix the recovery flow while connecting
      iwlwifi: mvm: don't mark TIDs that are not idle wrt BA as inactive
      iwlwifi: add a W/A for a scheduler hardware bug
      iwlwifi: mvm: reset the fw_dump_desc pointer after ASSERT
      iwlwifi: pcie: delete the Tx queue timer earlier upon firmware crash

Ganapathi Bhat (1):
      mwifiex: Do not change bss_type in change_virtual_intf

Gregory Greenman (1):
      iwlwifi: mvm: rs: add logs for the wrong antenna case

Gustavo A. R. Silva (2):
      ath9k: remove useless variable assignment in ath_mci_intr()
      wl18xx: add checks on wl18xx_top_reg_write() return value

Johannes Berg (25):
      iwlwifi: remove resp_pkt NULL checks
      iwlwifi: mvm: remove pointless num_stored condition
      iwlwifi: pcie: fix TVQM queue ID range check
      iwlwifi: mvm: avoid variable shadowing
      iwlwifi: mvm: use scnprintf() instead of snprintf()
      iwlwifi: use bitfield.h for some registers
      iwlwifi: mvm: track and report IBSS manager status to mac80211
      iwlwifi: mvm: make iwl_mvm_update_mcc() easier to follow
      iwlwifi: pcie: pull out common rfkill IRQ handling code
      iwlwifi: pcie: add fake RF-kill to debugfs
      iwlwifi: mvm: don't warn in queue sync on RF-kill
      iwlwifi: pcie: don't report RF-kill enabled while shutting down
      iwlwifi: pcie: remove pointless debugfs parsing for csr file
      iwlwifi: mvm: document status bits
      iwlwifi: pcie: use kstrtou32_from_user()
      iwlwifi: mvm: better link scan notification results length
      iwlwifi: simplify data tracepoint
      iwlwifi: fix TX tracing for non-linear SKBs
      iwlwifi: pcie: fix command completion name debug
      iwlwifi: mvm: docs: fix enum link, provide TX response link
      iwlwifi: mvm: disentangle union in TX status struct
      iwlwifi: mvm: add documentation for enum iwl_debug_cmds
      iwlwifi: document transmit buffer bits better
      iwlwifi: pcie: make iwl_pcie_apm_stop_master() return void
      iwlwifi: pcie: work around suspend/resume issue

Kalle Valo (2):
      Merge tag 'iwlwifi-next-for-kalle-2017-06-28' of git://git.kernel.org/.../iwlwifi/iwlwifi-next
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git

Liad Kaufman (5):
      iwlwifi: mvm: remove txq EMPTYING_DELBA state for DQA
      iwlwifi: mvm: disable dbg data collect when fw isn't alive
      iwlwifi: mvm: support aggregations on A000 HW
      iwlwifi: mvm: fix fw monitor 7000 HW recollecting
      iwlwifi: mvm: support TX on MONITOR iface

Luca Coelho (9):
      iwlwifi: mvm: make D0I3_END_CMD sync during system resume
      iwlwifi: mvm: support D0I3_END_CMD at the start of resume
      iwlwifi: remove useless iwl_free_nvm_data() function
      iwlwifi: mvm: fix nvm_data leak
      iwlwifi: pcie: don't disable bh when handling FW errors
      iwlwifi: mvm: reset the HW before dumping if HW error is detected
      iwlwifi: mvm: document assoc_beacon_arrive_time
      iwlwifi: mvm: print base HW address during init
      iwlwifi: pcie: reduce unwanted noise in the logs

Miaoqing Pan (5):
      ath9k: fix tx99 use after free
      ath9k: fix tx99 bus error
      ath9k: fix an invalid pointer dereference in ath9k_rng_stop()
      ath9k: avoid potential freezing during random generator read
      ath9k: Use mutex_lock to avoid potential race in start/stop rng

Mordechai Goodstein (2):
      iwlwifi: mvm: change the firmware name loading
      iwlwifi: mvm: support new flush API

Ping-Ke Shih (8):
      rtlwifi: Fix a2dp choppy while BT RSSI stays on threshold.
      rtlwifi: Do IQK only once to reduce wifi occupy antenna
      rtlwifi: Modify power mode parameters of 8723be and 8821ae.
      rtlwifi: Update some cases in btc_get function -- roam, 5G, AP mode, and return value.
      rtlwifi: Add return value to btc_set.
      rtlwifi: Add ap_num field for btcoexist
      rtlwifi: Fill ap_num field by driver
      rtlwifi: Add in_4way field for btcoexist

 MAINTAINERS                                        |   3 +
 drivers/net/wireless/ath/ath10k/mac.c              |   2 +-
 drivers/net/wireless/ath/ath10k/pci.c              |   2 +-
 drivers/net/wireless/ath/ath10k/sdio.c             |   4 +-
 drivers/net/wireless/ath/ath10k/thermal.c          |   2 +-
 drivers/net/wireless/ath/ath10k/wmi-tlv.c          |   2 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   2 -
 drivers/net/wireless/ath/ath9k/main.c              |   8 +-
 drivers/net/wireless/ath/ath9k/mci.c               |   2 +-
 drivers/net/wireless/ath/ath9k/rng.c               |  10 +-
 drivers/net/wireless/ath/ath9k/tx99.c              |  13 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/bus.h |  18 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |   4 +-
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    |  28 ++-
 .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.c |   1 +
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |  13 +-
 drivers/net/wireless/intel/iwlwifi/dvm/main.c      |   4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-a000.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |   1 +
 drivers/net/wireless/intel/iwlwifi/iwl-csr.h       |   4 +
 .../net/wireless/intel/iwlwifi/iwl-devtrace-data.h |  11 +-
 .../wireless/intel/iwlwifi/iwl-devtrace-iwlwifi.h  |  19 +-
 .../net/wireless/intel/iwlwifi/iwl-eeprom-parse.h  |   9 -
 drivers/net/wireless/intel/iwlwifi/iwl-fh.h        |  28 ++-
 drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h   |   1 +
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c |   2 +
 drivers/net/wireless/intel/iwlwifi/iwl-prph.h      |  17 +-
 drivers/net/wireless/intel/iwlwifi/iwl-trans.c     |   5 +-
 drivers/net/wireless/intel/iwlwifi/iwl-trans.h     |  19 +-
 drivers/net/wireless/intel/iwlwifi/mvm/d3.c        |  39 ++--
 .../net/wireless/intel/iwlwifi/mvm/debugfs-vif.c   |  22 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c   |  19 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-mac.h    |   1 +
 .../net/wireless/intel/iwlwifi/mvm/fw-api-scan.h   |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-tx.h |  89 +++++++--
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h    |  23 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c    |  10 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |   3 +
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |  63 ++++--
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |  30 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/nvm.c       |  43 +++--
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |  39 ++--
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c        |   6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       | 212 ++++++++++++++-------
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |   8 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |  70 +++++--
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c     |  93 ++++++---
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |  12 +-
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |  18 +-
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c       | 116 ++++++-----
 .../net/wireless/intel/iwlwifi/pcie/trans-gen2.c   |  28 +--
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    | 168 ++++++++++------
 drivers/net/wireless/intel/iwlwifi/pcie/tx-gen2.c  |  14 +-
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c       |  43 +++--
 drivers/net/wireless/marvell/libertas/mesh.c       |   5 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |   6 +-
 .../net/wireless/quantenna/qtnfmac/pearl/pcie.c    |   2 +-
 drivers/net/wireless/realtek/rtlwifi/base.c        | 102 ++++++++++
 drivers/net/wireless/realtek/rtlwifi/base.h        |   2 +
 .../realtek/rtlwifi/btcoexist/halbtcoutsrc.c       |  36 ++--
 drivers/net/wireless/realtek/rtlwifi/core.c        |   3 +
 drivers/net/wireless/realtek/rtlwifi/pci.c         |   4 +
 drivers/net/wireless/realtek/rtlwifi/ps.c          |  14 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/fw.c    |  10 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/hw.c    |   3 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/fw.c    |   8 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/hw.c    |   7 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/phy.c   |   3 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/sw.c    |   4 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/fw.c    |  10 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/sw.c    |   4 +-
 drivers/net/wireless/realtek/rtlwifi/wifi.h        |  16 ++
 drivers/net/wireless/rsi/rsi_91x_debugfs.c         |   2 +
 drivers/net/wireless/st/cw1200/cw1200_sdio.c       |   2 +-
 drivers/net/wireless/st/cw1200/cw1200_spi.c        |   2 +-
 drivers/net/wireless/ti/wl18xx/main.c              |   6 +-
 77 files changed, 1125 insertions(+), 535 deletions(-)
