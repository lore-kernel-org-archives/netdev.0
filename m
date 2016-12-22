From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2016-12-22
Date: Thu, 22 Dec 2016 17:11:27 +0200
Message-ID: <8760mcrobk.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

before the holidays a really small pull request for 4.10. I just want to
have the regressions in rtlwifi and ath9k fixed quickly so I send this
earlier than I normally would.

Please let me know if there are any problems.

Kalle

The following changes since commit ad688cdbb076833ba17fc65591cd0fe01900a5cf:

  stmmac: fix memory barriers (2016-12-19 11:05:02 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2016-12-22

for you to fetch changes up to 22b68b93ae2506bd56ee3bf232a51bc8ab955b56:

  rtlwifi: Fix kernel oops introduced with commit e49656147359 (2016-12-21 16:34:16 +0200)

----------------------------------------------------------------
wireless-drivers fixes for 4.10

All small fixes this time, especially important are the regression
fixes for rtlwifi and ath9k.

----------------------------------------------------------------
Arend Van Spriel (2):
      brcmfmac: fix memory leak in brcmf_cfg80211_attach()
      brcmfmac: fix uninitialized field in scheduled scan ssid configuration

Ben Greear (1):
      ath10k: free host-mem with DMA_BIRECTIONAL flag

Larry Finger (1):
      rtlwifi: Fix kernel oops introduced with commit e49656147359

Tobias Klausmann (1):
      ath9k: do not return early to fix rcu unlocking

 drivers/net/wireless/ath/ath10k/wmi.c              |    2 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |    2 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |    7 +++++--
 .../net/wireless/broadcom/brcm80211/brcmfmac/pno.c |    1 +
 drivers/net/wireless/realtek/rtlwifi/core.c        |    3 ++-
 5 files changed, 10 insertions(+), 5 deletions(-)
