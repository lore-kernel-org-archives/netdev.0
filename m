From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2017-03-02
Date: Thu,  2 Mar 2017 11:34:42 +0100
Message-ID: <20170302103443.18251-1-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:48858 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750703AbdCBLA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Mar 2017 06:00:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

As I mentioned in my other pull request, here's the change
for the average.h to make the precision easier to use.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 48cac18ecf1de82f76259a54402c3adb7839ad01:

  ipv6: orphan skbs in reassembly unit (2017-03-01 20:55:57 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-03-02

for you to fetch changes up to eb1e011a14748a1d9df9a7d7df9a5711721a1bdb:

  average: change to declare precision, not factor (2017-03-02 08:32:46 +0100)

----------------------------------------------------------------
This contains just the average.h change in order to get it
into the tree before adding new users through -next trees.

----------------------------------------------------------------
Johannes Berg (1):
      average: change to declare precision, not factor

 drivers/net/virtio_net.c                    |  2 +-
 drivers/net/wireless/ath/ath5k/ath5k.h      |  2 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00.h |  2 +-
 include/linux/average.h                     | 61 +++++++++++++++++++----------
 net/batman-adv/types.h                      |  2 +-
 net/mac80211/ieee80211_i.h                  |  2 +-
 net/mac80211/sta_info.h                     |  2 +-
 7 files changed, 47 insertions(+), 26 deletions(-)
