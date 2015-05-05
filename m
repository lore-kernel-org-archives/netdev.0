From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: wireless-drivers 2015-05-05
Date: Tue, 5 May 2015 20:00:42 +0300
Message-ID: <871tivt0w5.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here are few fixes for 4.1. Please let me know if there are problems.

Kalle

The following changes since commit 39376ccb1968ba9f83e2a880a8bf02ad5dea44e1:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf (2015-04-27 23:12:34 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2015-05-05

for you to fetch changes up to f673821864899153142365aca888435815ac93f0:

  ath9k: fix per-packet tx power configuration (2015-05-03 23:54:38 +0300)

----------------------------------------------------------------
iwlwifi:

* fix firmware API for -13.ucode
* fix RSSI handling that avoid bad roaming decision
* fix firmware debug
* fix MFUART operation
* fix ASSERT while restart the hardware (because of another ASSERT e.g)

ath9k:

* fix per-packet tx power configuration

rtlwifi:

* rtl8192cu: Fix kernel deadlock

----------------------------------------------------------------
Alexander Bondar (1):
      iwlwifi: mvm: Avoid signal based decisions if ave beacon RSSI is 0

Avraham Stern (1):
      iwlwifi: mvm: fix scan iteration complete notification handling

Avri Altman (1):
      iwlwifi: mvm: fix Tx Power firmware API

Emmanuel Grumbach (2):
      iwlwifi: mvm: don't stop the FW monitor too early
      iwlwifi: mvm: fix typo in CONFIG option

Eran Harary (1):
      iwlwifi: mvm: don't power off the device between INIT and OPER firmwares

Johannes Berg (1):
      iwlwifi: mvm: force quota update update after FW restart

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2015-04-28' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Larry Finger (1):
      rtlwifi: rtl8192cu: Fix kernel deadlock

Liad Kaufman (1):
      iwlwifi: pcie: prevent using unmapped memory in fw monitor

Lorenzo Bianconi (1):
      ath9k: fix per-packet tx power configuration

 drivers/net/wireless/ath/ath9k/xmit.c           |   52 +++++++++++-----------
 drivers/net/wireless/iwlwifi/iwl-fw-file.h      |    2 +
 drivers/net/wireless/iwlwifi/iwl-trans.h        |   41 +++++++++++------
 drivers/net/wireless/iwlwifi/mvm/d3.c           |    2 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h |   34 ++++++++++++++
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h  |   44 +-----------------
 drivers/net/wireless/iwlwifi/mvm/fw-api.h       |   13 ------
 drivers/net/wireless/iwlwifi/mvm/fw.c           |   54 +++++++++--------------
 drivers/net/wireless/iwlwifi/mvm/mac80211.c     |   26 +++++++++--
 drivers/net/wireless/iwlwifi/mvm/mvm.h          |    1 -
 drivers/net/wireless/iwlwifi/mvm/ops.c          |   10 +++++
 drivers/net/wireless/iwlwifi/mvm/rx.c           |    5 +++
 drivers/net/wireless/iwlwifi/mvm/scan.c         |    2 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c       |   17 +++----
 drivers/net/wireless/rtlwifi/usb.c              |    2 +-
 15 files changed, 161 insertions(+), 144 deletions(-)

-- 
Kalle Valo
