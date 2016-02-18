From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2016-02-18
Date: Thu, 18 Feb 2016 17:28:14 +0200
Message-ID: <87mvqyqbqp.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

I have some important fixes I would like to get 4.5 still, more info in
the signed tag. Please let me know if you have problems.

Kalle

The following changes since commit f9ead9beef3f44be0db4b542a8c2ce698fb1530e:

  Merge tag 'iwlwifi-for-kalle-2016-01-26_2' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2016-01-27 14:19:18 +0200)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2016-02-18

for you to fetch changes up to c699404db182836498bd9d9a36ef044de2cab4fd:

  Merge tag 'iwlwifi-for-kalle-2016-02-15' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2016-02-16 17:58:30 +0200)

----------------------------------------------------------------

rtlwifi

* fix broken VHT (802.11ac) support, reported by Linus

wlcore

* fix firmware initialisation regression on wl1271

iwlwifi

* fix a race that users reported when we try to load the firmware
  and the hardware rfkill interrupt triggers at the same time
* fix a very visible bug in scheduled scan: the firmware
  doesn't support scheduled scan with no profile configured and
  the supplicant sometimes requests such scheduled scans
* build system fix to be able to link iwlwifi statically into kernel
* firmware name update for 8265
* typo fix in return value

----------------------------------------------------------------
Anton Protopopov (1):
      iwlwifi: pcie: fix erroneous return value

Emil Goode (1):
      wlcore: Fix regression in wlcore_set_partition()

Emmanuel Grumbach (2):
      iwlwifi: dvm: remove a wrong dependency on m
      iwlwifi: pcie: fix RF-Kill vs. firmware load race

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2016-02-15' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Larry Finger (1):
      rtlwifi: fix broken VHT support

Luca Coelho (1):
      iwlwifi: mvm: don't allow sched scans without matches to be started

Oren Givon (1):
      iwlwifi: fix name of ucode loaded for 8265 series

 drivers/net/wireless/intel/iwlwifi/Kconfig         |    1 -
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c      |   42 ++++-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c       |    6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |    4 +
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |    9 +
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c       |    8 +-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |  188 ++++++++++++--------
 drivers/net/wireless/realtek/rtlwifi/rc.c          |    5 +
 drivers/net/wireless/ti/wlcore/io.c                |    8 +-
 drivers/net/wireless/ti/wlcore/io.h                |    4 +-
 10 files changed, 175 insertions(+), 100 deletions(-)

-- 
Kalle Valo
