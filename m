From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2017-03-21
Date: Tue, 21 Mar 2017 15:54:47 +0200
Message-ID: <87k27i68go.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

few smallish fixes for 4.11. Please let me know if there are any
problems.

Kalle

The following changes since commit 22a0e18eac7a9e986fec76c60fa4a2926d1291e2:

  net: properly release sk_frag.page (2017-03-15 15:37:45 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2017-03-21

for you to fetch changes up to 6be3b6cce1e225f189b68b4e84fc711d19b4277b:

  ath10k: fix incorrect wlan_mac_base in qca6174_regs (2017-03-20 17:11:31 +0200)

----------------------------------------------------------------
wireless-drivers fixes for 4.11

iwlwifi

* fix a user reported warning in DQA

mwifiex

* fix a potential double free
* fix lost early debug logs
* fix init wakeup warning message from device framework
* add Ganapathi and Xinming as maintainers

ath10k

* fix regression with QCA6174 during resume and firmware crash

----------------------------------------------------------------
Amitkumar Karwar (1):
      MAINTAINERS: update for mwifiex driver maintainers

Brian Norris (3):
      mwifiex: pcie: don't leak DMA buffers when removing
      mwifiex: set adapter->dev before starting to use mwifiex_dbg()
      mwifiex: uninit wakeup info when removing device

Ryan Hsu (1):
      ath10k: fix incorrect wlan_mac_base in qca6174_regs

Sara Sharon (1):
      iwlwifi: mvm: cleanup pending frames in DQA mode

 MAINTAINERS                                       |  2 ++
 drivers/net/wireless/ath/ath10k/hw.c              |  2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c |  5 +--
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c      | 11 +++---
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h      |  2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c       | 41 ++++++++++-------------
 drivers/net/wireless/marvell/mwifiex/main.c       | 11 +++---
 drivers/net/wireless/marvell/mwifiex/pcie.c       | 38 ++++++++++-----------
 8 files changed, 57 insertions(+), 55 deletions(-)
