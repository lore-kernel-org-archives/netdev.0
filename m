From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2016-04-13
Date: Wed, 13 Apr 2016 21:23:21 +0300
Message-ID: <87d1pts6zq.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

few very small fixes for 4.6. All but one are either build fixes or
memory leaks. More info in the signed tag below.

Please let me know if there are any problems.

Kalle

The following changes since commit 9a3492194eca6253ae7ba93c7a402cecad7f1c94:

  Merge branch 'AF_VSOCK-missed-wakeups' (2016-03-22 16:18:42 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2016-04-13

for you to fetch changes up to 15da5d11040c636cddf85bd93fd4abe85f02fc9f:

  Merge tag 'iwlwifi-for-kalle-2016-03-30' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2016-04-02 17:59:57 +0300)

----------------------------------------------------------------

wireless-drivers fixes for 4.6

b43

* fix memory leaks when removing the device

bcma

* fix building without OF_IRQ

rtlwifi

* fix gcc-6 indentation warning

iwlwifi

* lower the debug level of a benign print
* fix a memory leak

----------------------------------------------------------------
Arnd Bergmann (2):
      bcma: fix building without OF_IRQ
      rtlwifi: fix gcc-6 indentation warning

Emmanuel Grumbach (1):
      iwlwifi: pcie: lower the debug level for RSA semaphore access

Jia-Ju Bai (1):
      b43: Fix memory leaks in b43_bus_dev_ssb_init and b43_bus_dev_bcma_init

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2016-03-30' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Matti Gottlieb (1):
      iwlwifi: mvm: fix memory leak in paging

 drivers/bcma/main.c                                |   17 ++++-------------
 drivers/net/wireless/broadcom/b43/main.c           |    6 ++++--
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |    2 ++
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |    2 --
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |    4 ++--
 .../net/wireless/realtek/rtlwifi/rtl8821ae/dm.c    |    6 +++---
 6 files changed, 15 insertions(+), 22 deletions(-)
