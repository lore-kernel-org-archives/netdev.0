From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2017-07-21
Date: Fri, 21 Jul 2017 19:12:54 +0300
Message-ID: <87a83x3h15.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

important fixes for net which had accumulated while I was away. I only
applied the brcmfmac and rtlwifi patches only eight hours ago and I
haven't seen the kbuild report yet so they might have some build
breakage in theory. But the patches are so small so the chances that
they would break something are really small and so I send this to you
already now to not delay them any longer.

Please let me know if there are any problems.

Kalle

The following changes since commit 96080f697786e0a30006fcbcc5b53f350fcb3e9f:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-07-20 16:33:39 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2017-07-21

for you to fetch changes up to d755cbc26e8295ae8e5d30425364e093b4247a85:

  Merge tag 'iwlwifi-for-kalle-2017-07-21' of git://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2017-07-21 14:33:27 +0300)

----------------------------------------------------------------
wireless-drivers fixes for 4.13

Important, but small in size, fixes.

brcmfmac

* fix a regression in SDIO support introduced in v4.13-rc1

rtlwifi

* fix a regression in bluetooth coexistance introduced in v4.13-rc1

iwlwifi

* a few NULL pointer dereferences in the recovery flow

* a small but important fix for IBSS

* a one-liner fix for tracing, which was including too much data

----------------------------------------------------------------
Arend Van Spriel (1):
      brcmfmac: fix regression in brcmf_sdio_txpkt_hdalign()

Dan Carpenter (1):
      iwlwifi: missing error code in iwl_trans_pcie_alloc()

Emmanuel Grumbach (3):
      iwlwifi: dvm: prevent an out of bounds access
      iwlwifi: mvm: fix a NULL pointer dereference of error in recovery
      iwlwifi: fix tracing when tx only is enabled

Johannes Berg (1):
      iwlwifi: mvm: defer setting IWL_MVM_STATUS_IN_HW_RESTART

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2017-07-21' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Larry Finger (1):
      Revert "rtlwifi: btcoex: rtl8723be: fix ant_sel not work"

Luca Coelho (1):
      iwlwifi: mvm: handle IBSS probe_queue in a few missing places

Mordechai Goodstein (1):
      iwlwifi: pcie: fix unused txq NULL pointer dereference

 drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c |  3 ++-
 drivers/net/wireless/intel/iwlwifi/dvm/tx.c             |  2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-devtrace.h       |  4 ++--
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c       |  8 +++++++-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h            |  2 ++
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c            |  6 +++---
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c            | 15 ++++++++++++++-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c         |  3 ++-
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c            |  3 +++
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c     |  3 ---
 drivers/net/wireless/realtek/rtlwifi/wifi.h             |  1 -
 11 files changed, 36 insertions(+), 14 deletions(-)

-- 
Kalle Valo
