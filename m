From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2017-08-25
Date: Fri, 25 Aug 2017 16:37:57 +0300
Message-ID: <87zianvkcq.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's pull request to net tree for 4.13, more info in the signed tag
below. Please let me know if there are any problems.

Kalle

The following changes since commit e9bf53ab1ee34bb05c104bbfd2b77c844773f8e6:

  brcmfmac: feature check for multi-scheduled scan fails on bcm4343x devices (2017-08-14 11:09:30 +0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2017-08-25

for you to fetch changes up to 10a54d8196d11f6cc0db2f71249f93854cb9fe55:

  iwlwifi: pcie: move rx workqueue initialization to iwl_trans_pcie_alloc() (2017-08-24 16:49:00 +0300)

----------------------------------------------------------------
wireless-drivers fixes for 4.13

Only one iwlwifi patch this time.

iwlwifi

* fix multiple times reported lockdep warning found by new locking
  annotation introduced in v4.13-rc1

----------------------------------------------------------------
Luca Coelho (1):
      iwlwifi: pcie: move rx workqueue initialization to iwl_trans_pcie_alloc()

 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |  2 ++
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c       | 10 +---------
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |  9 +++++++++
 3 files changed, 12 insertions(+), 9 deletions(-)
