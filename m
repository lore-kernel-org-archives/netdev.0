From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2017-07-28
Date: Fri, 28 Jul 2017 17:02:24 +0300
Message-ID: <87h8xwvevj.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's a pull request for net, more info the signed tag below. Please
let me know if there are any problems.

Kalle

The following changes since commit d755cbc26e8295ae8e5d30425364e093b4247a85:

  Merge tag 'iwlwifi-for-kalle-2017-07-21' of git://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2017-07-21 14:33:27 +0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2017-07-28

for you to fetch changes up to 5f5d03143de5e0c593da4ab18fc6393c2815e108:

  brcmfmac: fix memleak due to calling brcmf_sdiod_sgtable_alloc() twice (2017-07-27 14:03:14 +0300)

----------------------------------------------------------------
wireless-drivers fixes for 4.13

Two fixes for for brcmfmac, the crash was reported by two people
already so it's a high priority fix.

brcmfmac

* fix a crash in skb headroom handling in v4.13-rc1
* fix a memory leak due to a merge error in v4.6

----------------------------------------------------------------
Arend Van Spriel (1):
      brcmfmac: fix memleak due to calling brcmf_sdiod_sgtable_alloc() twice

Daniel Stone (1):
      brcmfmac: Don't grow SKB by negative size

 drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c | 2 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c | 5 -----
 2 files changed, 1 insertion(+), 6 deletions(-)
