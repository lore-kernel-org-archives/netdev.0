From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2017-05-08
Date: Mon,  8 May 2017 16:46:21 +0200
Message-ID: <20170508144622.19986-1-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35380 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754315AbdEHOq2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 8 May 2017 10:46:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Thanks for merging the rate fix quickly the other day. I've got a
few more fixes lined up, so this time as a pull request.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 4ac4d584886a4f47f8ff3bca0f32ff9a2987d3e5:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-05-04 12:26:43 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-05-08

for you to fetch changes up to 6406c91943a0f29b6e8786921aaa038663e08055:

  cfg80211: fix multi scheduled scan kernel-doc (2017-05-08 13:09:38 +0200)

----------------------------------------------------------------
A couple more fixes:
 * don't try to authenticate during reconfiguration, which causes
   drivers to get confused
 * fix a kernel-doc warning for a recently merged change
 * fix MU-MIMO group configuration (relevant only for monitor mode)
 * more rate flags fix: remove stray RX_ENC_FLAG_40MHZ
 * fix IBSS probe response allocation size

----------------------------------------------------------------
Johannes Berg (4):
      mac80211: properly remove RX_ENC_FLAG_40MHZ
      nl80211: correctly validate MU-MIMO groups
      mac80211: fix IBSS presp allocation size
      cfg80211: fix multi scheduled scan kernel-doc

Luca Coelho (1):
      mac80211: bail out from prep_connection() if a reconfig is ongoing

 drivers/net/wireless/ath/ath9k/ar9003_mac.c    | 2 +-
 drivers/net/wireless/ath/ath9k/mac.c           | 4 ++--
 drivers/net/wireless/intel/iwlegacy/4965-mac.c | 4 +++-
 drivers/net/wireless/intel/iwlwifi/dvm/rx.c    | 4 +++-
 drivers/net/wireless/mac80211_hwsim.c          | 8 +++++++-
 include/net/cfg80211.h                         | 2 +-
 include/net/mac80211.h                         | 2 --
 net/mac80211/ibss.c                            | 2 ++
 net/mac80211/mlme.c                            | 4 ++++
 net/wireless/nl80211.c                         | 4 ++--
 10 files changed, 25 insertions(+), 11 deletions(-)
