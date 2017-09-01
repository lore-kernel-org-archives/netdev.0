From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2017-09-01
Date: Fri, 01 Sep 2017 17:34:43 +0300
Message-ID: <878thyqygs.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:49984 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751991AbdIAOer (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 10:34:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here's a pull request to net-next for 4.14. If the merge window opens on
Sunday I'm planning to have this as the last one.

Please let me know if there are any problems.

Kalle

The following changes since commit d081a16db80ef7a260fb178aa1199e01f7432625:

  net: bcmgenet: Do not return from void function (2017-08-29 22:39:51 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2017-09-01

for you to fetch changes up to eb464d4a8d092a793b97b724cd3cc6eeb229232a:

  Merge ath-next from git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/ath.git (2017-08-31 21:34:22 +0300)

----------------------------------------------------------------
wireless-drivers-next patches for 4.14

Few last patches for 4.14, nothing really major here.

Major changes:

wil6210

* support FW RSSI reporting (by mistake this was accidentally
  mentioned already in the previous pull request, but now it's really
  included)

* make debugfs optional, adds new Kconfig option CONFIG_WIL6210_DEBUGFS

qtnfmac

* implement 64-bit DMA support

----------------------------------------------------------------
Andy Shevchenko (1):
      ath10k: switch to use new generic UUID API

Arvind Yadav (2):
      ath6kl: constify usb_device_id
      ath9k: constify usb_device_id

Bhumika Goyal (1):
      ath9k: make ath_ps_ops structures as const

Bjorn Andersson (1):
      wcn36xx: Introduce mutual exclusion of fw configuration

Dan Carpenter (2):
      rsi: update some comments
      rsi: missing unlocks on error paths

David Spinadel (1):
      iwlwifi: mvm: Avoid deferring non bufferable frames

Dedy Lansky (4):
      wil6210: support FW RSSI reporting
      wil6210: store FW RF calibration result
      wil6210: move pre-FW configuration to separate function
      wil6210: clear PAL_UNIT_ICR part of device reset

Emmanuel Grumbach (1):
      iwlwifi: mvm: bump API to 34 for 8000 and up

Erik Stromdahl (1):
      ath10k: sdio: remove unused struct member

Gabriel Craciunescu (1):
      ath10k: ath10k_htt_rx_amsdu_allowed() use ath10k_dbg()

Gidon Studinski (2):
      wil6210: move vring_idle_trsh definition to wil6210_priv
      wil6210: make debugfs compilation optional

Gustavo A. R. Silva (1):
      rtlwifi: rtl8723be: fix duplicated code for different branches

Hamad Kadmany (2):
      wil6210: protect against invalid length of tx management frame
      wil6210: fix interface-up check

Hans de Goede (1):
      brcmfmac: Log chip id and revision

Hauke Mehrtens (1):
      ath10k: activate user space firmware loading again

Himanshu Jha (1):
      rsi: remove memset before memcpy

Kalle Valo (2):
      Merge tag 'iwlwifi-next-for-kalle-2017-08-30' of git://git.kernel.org/.../iwlwifi/iwlwifi-next
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git

Lazar Alexei (1):
      wil6210: align to latest auto generated wmi.h

Liad Kaufman (1):
      iwlwifi: fix long debug print

Lior David (3):
      wil6210: ratelimit errors in TX/RX interrupts
      wil6210: increase connect timeout
      wil6210: ensure P2P device is stopped before removing interface

Maya Erez (3):
      wil6210: check no_fw_recovery in resume failure recovery
      wil6210: add statistics for suspend time
      wil6210: notify wiphy on wowlan support

Rakesh Pillai (1):
      ath10k: fix memory leak in rx ring buffer allocation

Ryan Hsu (3):
      ath10k: fix napi_poll budget overflow
      ath10k: add the PCI PM core suspend/resume ops
      ath10k: configure and enable the wakeup capability

Sergey Matyukevich (5):
      qtnfmac: drop -D__CHECK_ENDIAN from cflags
      qtnfmac: module param sanity check
      qtnfmac: modify qtnf_map_bar not to return NULL
      qtnfmac: fix free_xfer_buffer cleanup
      qtnfmac: implement 64-bit dma support

Stanislaw Gruszka (1):
      rt2800: fix TX_PIN_CFG setting for non MT7620 chips

 drivers/net/wireless/ath/ath10k/core.c             |  14 +-
 drivers/net/wireless/ath/ath10k/core.h             |   2 +-
 drivers/net/wireless/ath/ath10k/debug.c            |   6 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |  19 +-
 drivers/net/wireless/ath/ath10k/mac.c              |   1 +
 drivers/net/wireless/ath/ath10k/pci.c              |  50 +-
 drivers/net/wireless/ath/ath10k/sdio.c             |   4 -
 drivers/net/wireless/ath/ath10k/sdio.h             |   2 -
 drivers/net/wireless/ath/ath10k/wow.c              |  14 +
 drivers/net/wireless/ath/ath10k/wow.h              |   1 +
 drivers/net/wireless/ath/ath6kl/usb.c              |   2 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c           |   2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   2 +-
 drivers/net/wireless/ath/ath9k/init.c              |   2 +-
 drivers/net/wireless/ath/wcn36xx/main.c            |  52 +-
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h         |   3 +
 drivers/net/wireless/ath/wil6210/Kconfig           |  12 +
 drivers/net/wireless/ath/wil6210/Makefile          |   2 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |  84 ++-
 drivers/net/wireless/ath/wil6210/debugfs.c         |  27 +-
 drivers/net/wireless/ath/wil6210/interrupt.c       |  14 +-
 drivers/net/wireless/ath/wil6210/main.c            |  42 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |   3 +
 drivers/net/wireless/ath/wil6210/pm.c              |  27 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |   6 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |  20 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |  14 +-
 drivers/net/wireless/ath/wil6210/wmi.h             | 720 ++++++++++++++-------
 .../broadcom/brcm80211/brcmfmac/firmware.c         |   3 +
 drivers/net/wireless/intel/iwlwifi/cfg/8000.c      |   4 +-
 drivers/net/wireless/intel/iwlwifi/cfg/9000.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/cfg/a000.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c |   9 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |   9 +-
 drivers/net/wireless/quantenna/qtnfmac/Makefile    |   4 -
 .../net/wireless/quantenna/qtnfmac/pearl/pcie.c    | 101 ++-
 .../wireless/quantenna/qtnfmac/pearl/pcie_ipc.h    |  10 +-
 .../quantenna/qtnfmac/pearl/pcie_regs_pearl.h      |   1 +
 drivers/net/wireless/ralink/rt2x00/rt2800lib.c     |   5 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/dm.c    |   8 +-
 drivers/net/wireless/rsi/rsi_91x_mac80211.c        |  25 +-
 drivers/net/wireless/rsi/rsi_91x_sdio.c            |   1 -
 drivers/net/wireless/rsi/rsi_91x_usb.c             |   1 -
 43 files changed, 931 insertions(+), 401 deletions(-)
