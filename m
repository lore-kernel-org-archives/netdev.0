From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2016-10-30
Date: Sun, 30 Oct 2016 11:20:46 +0200
Message-ID: <87insaw5u9.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

few fixes for 4.9. I tagged this on the plane over a slow mosh
connection while travelling to Plumbers so I might have done something
wrong, please check more carefully than usually. For example I had to
redo the signed tag because of some whitespace damage.

Please let me know if there are any problems.

Kalle

The following changes since commit 67f0160fe34ec5391a428603b9832c9f99d8f3a1:

  MAINTAINERS: Update qlogic networking drivers (2016-10-26 23:29:12 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2016-10-30

for you to fetch changes up to d3532ea6ce4ea501e421d130555e59edc2945f99:

  brcmfmac: avoid maybe-uninitialized warning in brcmf_cfg80211_start_ap (2016-10-27 18:04:54 +0300)

----------------------------------------------------------------
wireless-drivers fixes for 4.9

iwlwifi

* some fixes for suspend/resume with unified FW images
* a fix for a false-positive lockdep report
* a fix for multi-queue that caused an unnecessary 1 second latency
* a fix for an ACPI parsing bug that caused a misleading error message

brcmfmac

* fix a variable uninitialised warning in brcmf_cfg80211_start_ap()

----------------------------------------------------------------
Arnd Bergmann (1):
      brcmfmac: avoid maybe-uninitialized warning in brcmf_cfg80211_start_ap

Haim Dreyfuss (1):
      iwlwifi: mvm: comply with fw_restart mod param on suspend

Johannes Berg (1):
      iwlwifi: pcie: mark command queue lock with separate lockdep class

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2015-10-25' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Luca Coelho (4):
      iwlwifi: mvm: use ssize_t for len in iwl_debugfs_mem_read()
      iwlwifi: mvm: fix d3_test with unified D0/D3 images
      iwlwifi: pcie: fix SPLC structure parsing
      iwlwifi: mvm: fix netdetect starting/stopping for unified images

Sara Sharon (1):
      iwlwifi: mvm: wake the wait queue when the RX sync counter is zero

 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/d3.c        |   49 +++++++++---
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c   |    4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |    3 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |    1 +
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |    1 +
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |    3 +-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |   33 ++++++--
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |   79 ++++++++++++--------
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c       |    8 ++
 10 files changed, 129 insertions(+), 54 deletions(-)
