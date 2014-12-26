From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2014-12-26
Date: Fri, 26 Dec 2014 14:09:42 +0200
Message-ID: <87egrm7gu1.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's my first wireless-drivers pull request after John's "retirement".
I'll start this with few fixes for 3.19, changelog below.

I used a signed tag to create this pull request, I hope that's ok.
Please let me know if there are any problems.

Kalle


The following changes since commit 02d6a746c3f0cdd6f8aad0afd0b32d4646d6525e:

  Merge branch 'for-upstream' of git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth (2014-12-19 15:47:32 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2014-12-26

for you to fetch changes up to 8975842bed0840f314281c9fbf021a1d29537cf0:

  brcmfmac: Do not crash if platform data is not populated (2014-12-24 15:26:46 +0200)

----------------------------------------------------------------
o Paul made a Kconfig dependency fix to ipw2200, it was not possible to
  enable that driver because Wireless Extensions is now disabled by default.

o Mika fixed brcmfmac not to crash when platform data is not populated

o Emmanuel provided few fixes to iwlwifi, he says:

  "I have here new device IDs and a fix for double free bug I
  introduced. I also fix an issue with the RFKILL interrupt - the HW
  needs us to ACK the interrupt again after we reset it. Liad fixes an
  issue with the firmware debugging infrastructure. While working on
  torture scenarios of firmware restarts, Eliad found an issue which
  he fixed."

----------------------------------------------------------------
Eliad Peller (1):
      iwlwifi: mvm: clear IN_HW_RESTART flag on stop()

Emmanuel Grumbach (3):
      iwlwifi: pcie: re-ACK all interrupts after device reset
      iwlwifi: don't double free a pointer if no FW was found
      iwlwifi: add new device IDs for 3165

Kalle Valo (1):
      Merge tag 'iwlwifi-fixes-for-kalle-2014-12-18' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Liad Kaufman (1):
      iwlwifi: pcie: limit fw chunk sizes given to fh

Mika Westerberg (1):
      brcmfmac: Do not crash if platform data is not populated

Paul Bolle (1):
      ipw2200: select CFG80211_WEXT

 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c |    4 ++--
 drivers/net/wireless/ipw2x00/Kconfig             |    3 ++-
 drivers/net/wireless/iwlwifi/iwl-drv.c           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-fh.h            |    1 +
 drivers/net/wireless/iwlwifi/mvm/mac80211.c      |   15 +++++++++++++--
 drivers/net/wireless/iwlwifi/pcie/drv.c          |    4 ++++
 drivers/net/wireless/iwlwifi/pcie/trans.c        |   17 +++++++++++------
 7 files changed, 34 insertions(+), 12 deletions(-)

-- 
Kalle Valo
