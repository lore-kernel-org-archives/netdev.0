From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2016-09-08
Date: Thu, 08 Sep 2016 14:31:56 +0300
Message-ID: <8737latyoj.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

few important, but as can be seen from the diffstat, really small fixes
for 4.8. Please let me know if you have any problems.

Kalle

The following changes since commit bb87f02b7e4ccdb614a83cbf840524de81e9b321:

  Merge ath-current from ath.git (2016-08-29 21:39:04 +0300)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2016-09-08

for you to fetch changes up to a0714125d11bcf21599b08b25fdaf384c0db6712:

  Merge ath-current from ath.git (2016-09-07 20:16:37 +0300)

----------------------------------------------------------------

wireless-drivers fixes for 4.8

iwlwifi

* fix P2P dump trigger
* prevent a potential null dereference in iwlmvm
* prevent an uninitialized value from being returned in iwlmvm
* advertise support for channel width change in AP mode

ath10k

* fix racy rx status retrieval from htt context
* QCA9887 support is not experimental anymore, remove the warning message

ath9k

* fix regression with led GPIOs
* fix AR5416 GPIO access warning

brcmfmac

* avoid potential stack overflow in brcmf_cfg80211_start_ap()

----------------------------------------------------------------
Arend Van Spriel (1):
      brcmfmac: avoid potential stack overflow in brcmf_cfg80211_start_ap()

Ashok Raj Nagarajan (1):
      ath10k: fix get rx_status from htt context

Emmanuel Grumbach (2):
      iwlwifi: mvm: consider P2p device type for firmware dump triggers
      iwlwifi: mvm: don't use ret when not initialised

Giedrius Statkevičius (1):
      ath9k: bring back direction setting in ath9k_{start_stop}

Kalle Valo (2):
      Merge tag 'iwlwifi-for-kalle-2016-08-29' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge ath-current from ath.git

Miaoqing Pan (1):
      ath9k: fix AR5416 access GPIO warning

Mohammed Shafi Shajakhan (1):
      ath10k: Remove driver log suggesting QCA9887 support is experimental

Peer, Ilan (1):
      iwlwifi: mvm: Advertise support for AP channel width change

Sharon Dvir (1):
      iwlwifi: mvm: check if vif is NULL before using it

 drivers/net/wireless/ath/ath10k/htt_rx.c           |   10 +++++-----
 drivers/net/wireless/ath/ath10k/pci.c              |    1 -
 drivers/net/wireless/ath/ath9k/hw.c                |    4 ++--
 drivers/net/wireless/ath/ath9k/main.c              |    9 +++++++--
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c    |    3 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.h    |    3 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |    1 +
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |    2 ++
 9 files changed, 22 insertions(+), 13 deletions(-)
