From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2017-04-27
Date: Thu, 27 Apr 2017 12:41:37 +0300
Message-ID: <87a872xk4u.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:38808 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752574AbdD0Jlr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 05:41:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here's a pull request for net-next, more info in the tag below. This
should be the last pull request to net-next for 4.12. Please let me know
if there are any problems.

Kalle

The following changes since commit 7acedaf5c4355f812cfef883ac28bf15f7d9205e:

  net: move xdp_prog field in RX cache lines (2017-04-25 16:25:36 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2017-04-27

for you to fetch changes up to 47d272f0f9887343f4e4d31bb22910b141b96654:

  Merge tag 'iwlwifi-next-for-kalle-2017-04-26' of git://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-next (2017-04-26 14:21:00 +0300)

----------------------------------------------------------------
wireless-drivers-next patches for 4.12

Few remaining patches for 4.12 submitted during the last week.

Major changes:

iwlwifi

* the firmware for 7265D and 3168 NICs is frozen at version 29

* more support for the upcoming A000 series

----------------------------------------------------------------
Colin Ian King (1):
      orinoco: fix spelling mistake: "Registerred" -> "Registered"

Dor Shaish (1):
      iwlwifi: mvm: freeze 7265D and 3168 on API version 29

Haim Dreyfuss (1):
      iwlwifi: mvm: Ignore wifi mcc update in the driver while associated

James Hughes (2):
      brcmfmac: Ensure pointer correctly set if skb data location changes
      brcmfmac: Make skb header writable before use

Johannes Berg (6):
      iwlwifi: mvm: make iwl_run_unified_mvm_ucode() static
      iwlwifi: mvm: avoid variable shadowing
      iwlwifi: pcie: remove superfluous trans->dev assignment
      iwlwifi: don't leak memory on allocation failure
      iwlwifi: remove module loading failure message
      iwlwifi: pcie: apply no-reclaim logic only to group 0

Kalle Valo (1):
      Merge tag 'iwlwifi-next-for-kalle-2017-04-26' of git://git.kernel.org/.../iwlwifi/iwlwifi-next

Larry Finger (1):
      rtlwifi: rtl8821ae: setup 8812ae RFE according to device type

Liad Kaufman (2):
      iwlwifi: pcie: support debug applying on a000 hw
      iwlwifi: gen2: support nmi triggering from host

Maksim Salau (1):
      orinoco_usb: Fix buffer on stack

Mordechai Goodstein (1):
      iwlwifi: mvm: scan: avoid "big" prints

Pan Bian (3):
      mt7601u: check return value of alloc_skb
      libertas: check return value of alloc_workqueue
      rndis_wlan: add return value validation

Sara Sharon (12):
      iwlwifi: mvm: support new rate flags
      iwlwifi: mvm: don't reserve queue in TVQM mode
      iwlwifi: mvm: map cab_queue to different txq_id
      iwlwifi: mvm: move internally to use bigger INVALID_TXQ
      iwlwifi: mvm: remove color definition
      iwlwifi: mvm: use defines instead of variables for shared dwell times
      iwlwifi: mvm: remove references to queue_info in new TX path
      iwlwifi: mvm: support station type API
      iwlwifi: move to 512 queues
      iwlwifi: rename wait_for_tx_queues_empty
      iwlwifi: mvm: memset binding before setting values
      iwlwifi: adjust NVM parsing APIs for new a000 method

Sharon Dvir (2):
      iwlwifi: mvm: check if returned value is NULL
      iwlwifi: mvm: handle possible BIOS bug

 .../wireless/broadcom/brcm80211/brcmfmac/core.c    |  23 +--
 drivers/net/wireless/intel/iwlwifi/dvm/lib.c       |   2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/mac80211.c  |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-7000.c      |   4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-a000.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c       |  15 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h   |   2 +
 drivers/net/wireless/intel/iwlwifi/iwl-io.c        |   3 +
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c |  32 ++-
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.h |  16 +-
 drivers/net/wireless/intel/iwlwifi/iwl-prph.h      |   1 +
 drivers/net/wireless/intel/iwlwifi/iwl-trans.h     |  10 +-
 drivers/net/wireless/intel/iwlwifi/mvm/binding.c   |   4 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-mac.h    |   5 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rs.h |  28 ++-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-sta.h    |  38 ++--
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        | 161 ++++++++-------
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |  11 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |  37 ++--
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |  10 +-
 drivers/net/wireless/intel/iwlwifi/mvm/nvm.c       |   9 +-
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |   9 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c        |  11 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rx.c        |   4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |   4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |  86 +++-----
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       | 229 ++++++++++++++-------
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |   7 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |  13 +-
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c     |  96 ++++++---
 .../net/wireless/intel/iwlwifi/pcie/ctxt-info.c    |   4 +
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |   7 +-
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c       |   2 +-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |   5 +-
 drivers/net/wireless/intersil/orinoco/main.c       |   2 +-
 .../net/wireless/intersil/orinoco/orinoco_usb.c    |  21 +-
 drivers/net/wireless/marvell/libertas/if_spi.c     |   5 +
 drivers/net/wireless/mediatek/mt7601u/mcu.c        |  10 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/phy.c   | 122 +++++++++--
 .../net/wireless/realtek/rtlwifi/rtl8821ae/reg.h   |   1 +
 drivers/net/wireless/rndis_wlan.c                  |   4 +
 42 files changed, 671 insertions(+), 388 deletions(-)
