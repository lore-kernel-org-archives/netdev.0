From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: pull-request: wireless-drivers 2015-03-24
Date: Tue, 24 Mar 2015 08:29:54 +0200
Message-ID: <87h9tadi1p.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here are few more fixes I would like to still get to 4.0 if possible,
detailed info in the tag below. Please let me know if there are any
problems.

Kalle

The following changes since commit 3f1615340acea54e21f4b9d4d65921540dca84b2:

  brcmfmac: Perform bound checking on vendor command buffer (2015-03-07 10:52:30 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2015-03-24

for you to fetch changes up to 6ae4ccfee09efe5baa3951d1c1d27050a46a1469:

  Merge tag 'iwlwifi-for-kalle-2014-03-22' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2015-03-23 06:43:43 +0200)

----------------------------------------------------------------

iwlwifi:

* avoid panic with lots of IBSS stations
* Fix dvm's behavior after suspend resume
* Allow to keep connection after CSA failure
* Remove a noisy by harmless WARN_ON
* New device IDs

rtlwifi:

* fix IOMMU mapping leak in AP mode

brcmfmac:

* disable MBSS feature for BCM43362 to get AP mode working again

ath9k:

* disable Transmit Power Control (TPC) again due to regressions

* fix beaconing issue with AP+STA setup

----------------------------------------------------------------
Arend van Spriel (1):
      brcmfmac: disable MBSS feature for BCM43362

Emmanuel Grumbach (2):
      iwlwifi: dvm: drop VO packets when mac80211 tells us to
      iwlwifi: dvm: run INIT firmware again upon .start()

Felix Fietkau (2):
      ath9k: fix tracking of enabled AP beacons
      ath9k: disable TPC support again (for now)

Johannes Berg (3):
      iwlwifi: mvm: disconnect if CSA time event fails scheduling
      iwlwifi: mvm: protect rate scaling against non-mvm IBSS stations
      iwlwifi: mvm: remove WARN_ON for invalid BA notification

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2014-03-22' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Larry Finger (1):
      rtlwifi: Fix IOMMU mapping leak in AP mode

Oren Givon (1):
      iwlwifi: add new 3165 series PCI IDs

 drivers/net/wireless/ath/ath9k/beacon.c           |   20 ++++++++++-------
 drivers/net/wireless/ath/ath9k/common.h           |    2 +-
 drivers/net/wireless/ath/ath9k/hw.c               |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/feature.c |    3 ++-
 drivers/net/wireless/iwlwifi/dvm/dev.h            |    1 -
 drivers/net/wireless/iwlwifi/dvm/mac80211.c       |   17 ++++++++-------
 drivers/net/wireless/iwlwifi/dvm/ucode.c          |    5 -----
 drivers/net/wireless/iwlwifi/mvm/rs.c             |   24 +++++++++++++++++++--
 drivers/net/wireless/iwlwifi/mvm/time-event.c     |    2 ++
 drivers/net/wireless/iwlwifi/mvm/tx.c             |    6 ++++--
 drivers/net/wireless/iwlwifi/pcie/drv.c           |    6 ++++--
 drivers/net/wireless/rtlwifi/pci.c                |   12 ++++++++++-
 12 files changed, 68 insertions(+), 32 deletions(-)
