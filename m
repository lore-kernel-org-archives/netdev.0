From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2015-07-20
Date: Mon, 20 Jul 2015 18:36:30 +0300
Message-ID: <87lheasuwx.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here are few fixes for 4.2, should not have anything out of ordinary.
Please let me know if there are any issues.

Kalle

The following changes since commit 145c37084e3e6584b95f82361922965cc3af41bf:

  Doc: z8530book: Fix typo in API-z8530-sync-txdma-open.html (2015-07-10 23:45:31 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2015-07-20

for you to fetch changes up to df2cd4586f177acf9493dee079fc7d18268c5f54:

  Merge tag 'iwlwifi-for-kalle-2015-06-12' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2015-07-17 11:19:08 +0300)

----------------------------------------------------------------

ath9k:

* fix device ID check for AR956x

iwlwifi:

* bug fixes specific for 8000 series
* fix a crash in time events
* fix a crash in PCIe transport
* fix BT Coex code that prevented association on certain
  devices (3160).
* revert the new RBD allocation model because it introduced
  a bug when running on weak VM setups.
* new device IDs

----------------------------------------------------------------
Avraham Stern (1):
      iwlwifi: mvm: Add preemptive flag to scheulded scan

Dreyfuss, Haim (1):
      iwlwifi: pcie: Fix bug in NIC's PM registers access

Emmanuel Grumbach (4):
      iwlwifi: mvm: fix antenna selection when BT is active
      iwlwifi: pcie: don't panic if pcie transport alloc fails
      iwlwifi: pcie: prepare the device before accessing it
      Revert "iwlwifi: pcie: New RBD allocation model"

Felix Fietkau (1):
      ath9k_hw: fix device ID check for AR956x

Johannes Berg (1):
      iwlwifi: mvm: check time-event vif to avoid bad deletion

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2015-06-12' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Liad Kaufman (1):
      iwlwifi: nvm: remove mac address byte swapping in 8000 family

Matti Gottlieb (1):
      iwlwifi: mvm: Avoid accessing Null pointer when setting igtk

Oren Givon (1):
      iwlwifi: edit the 3165 series and 8000 series PCI IDs

 drivers/net/wireless/ath/ath9k/hw.c            |    1 +
 drivers/net/wireless/iwlwifi/iwl-fh.h          |    6 +
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c   |   12 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h |    3 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c        |    3 +
 drivers/net/wireless/iwlwifi/mvm/sta.c         |    3 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.c  |    2 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c          |    2 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c        |    5 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h   |   51 +--
 drivers/net/wireless/iwlwifi/pcie/rx.c         |  414 +++++-------------------
 drivers/net/wireless/iwlwifi/pcie/trans.c      |   52 +--
 12 files changed, 144 insertions(+), 410 deletions(-)

-- 
Kalle Valo
