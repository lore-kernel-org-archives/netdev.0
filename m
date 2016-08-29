From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2016-08-29
Date: Mon, 29 Aug 2016 22:02:08 +0300
Message-ID: <87h9a3iekv.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

I'm quite backlogged after coming back from my vacation but luckily it
has been pretty quiet. Here is the first batch of patches for 4.8, quite
simple actually and not really anything special to mention. More to come
later, most probably next week. Please let me know if there are any
problems.

Kalle

The following changes since commit 184ca823481c99dadd7d946e5afd4bb921eab30d:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-08-17 17:26:58 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2016-08-29

for you to fetch changes up to bb87f02b7e4ccdb614a83cbf840524de81e9b321:

  Merge ath-current from ath.git (2016-08-29 21:39:04 +0300)

----------------------------------------------------------------

wireless-drivers fixes for 4.8

ath9k

* fix regression in client mode beacon configuration
* fix a station pointer which resulted in spurious crashes

mwifiex

* fix large amsdu packets causing firmware hang

brcmfmac

* fix deadlock when removing interface
* fix use of mutex in atomic context

----------------------------------------------------------------
Cathy Luo (1):
      mwifiex: fix large amsdu packets causing firmware hang

Felix Fietkau (2):
      ath9k: fix client mode beacon configuration
      ath9k: fix using sta->drv_priv before initializing it

Kalle Valo (1):
      Merge ath-current from ath.git

mhiramat@kernel.org (2):
      brcmfmac: Check rtnl_lock is locked when removing interface
      brcmfmac: Change vif_event_lock to spinlock

 drivers/net/wireless/ath/ath9k/main.c              |    9 ++++---
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |   26 ++++++++++----------
 .../broadcom/brcm80211/brcmfmac/cfg80211.h         |    2 +-
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    |    2 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.c |    8 +++---
 .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.h |    2 +-
 drivers/net/wireless/marvell/mwifiex/11n_aggr.c    |    3 ++-
 7 files changed, 28 insertions(+), 24 deletions(-)
