From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2017-09-08
Date: Fri, 08 Sep 2017 18:50:01 +0300
Message-ID: <87o9qljil2.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

few fixes to net tree for 4.14. Note that this pull request contains the
iwlwifi fix Linus hopes to have by end of the merge window. Please let
me know if there are any problems.

Kalle

The following changes since commit 8e0deed92406d93ae0365cb8a6134db5721e7aca:

  tipc: remove unnecessary call to dev_net() (2017-09-06 21:25:52 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2017-09-08

for you to fetch changes up to f957dd3c8db2781c8a334b166800788feb618625:

  brcmfmac: feature check for multi-scheduled scan fails on bcm4345 devices (2017-09-08 12:25:24 +0300)

----------------------------------------------------------------
wireless-drivers fixes for 4.14

Few fixes to regressions introduced in the last one or two releases.
The iwlwifi fix is for a regression reported by Linus.

rtlwifi

* fix two antenna selection related bugs

iwlwifi

* fix regression with older firmwares

brcmfmac

* workaround firmware crash for bcm4345

----------------------------------------------------------------
Ian W MORRISON (1):
      brcmfmac: feature check for multi-scheduled scan fails on bcm4345 devices

Larry Finger (2):
      rtlwifi: btcoexist: Fix breakage of ant_sel for rtl8723be
      rtlwifi: btcoexist: Fix antenna selection code

Luca Coelho (1):
      iwlwifi: mvm: only send LEDS_CMD when the FW supports it

 .../wireless/broadcom/brcm80211/brcmfmac/feature.c |  3 ++-
 drivers/net/wireless/intel/iwlwifi/fw/file.h       |  1 +
 drivers/net/wireless/intel/iwlwifi/mvm/led.c       |  3 ++-
 .../realtek/rtlwifi/btcoexist/halbtc8723b2ant.c    |  5 ++++-
 .../realtek/rtlwifi/btcoexist/halbtcoutsrc.c       | 23 +++++++++++++++-------
 5 files changed, 25 insertions(+), 10 deletions(-)
