From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2017-01-06
Date: Fri,  6 Jan 2017 13:37:20 +0100
Message-ID: <20170106123721.10970-1-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:59746 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967077AbdAFMiN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 07:38:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here's another fix for something I noticed while reviewing the code in
a new suggested patch that added another netlink socket destroy path.

Since the new patch would otherwise cause conflicts, it might be good
to pull net or Linus's next RC containing it into net-next, if you can.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 35f432a03e41d3bf08c51ede917f94e2288fbe8c:

  mac80211: initialize fast-xmit 'info' later (2017-01-02 11:28:25 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-01-06

for you to fetch changes up to 753aacfd2e95df6a0caf23c03dc309020765bea9:

  nl80211: fix sched scan netlink socket owner destruction (2017-01-05 10:59:53 +0100)

----------------------------------------------------------------
Another single fix, to correctly handle destruction of a
single netlink socket having ownership of multiple objects
(scheduled scan requests and interfaces.)

----------------------------------------------------------------
Johannes Berg (1):
      nl80211: fix sched scan netlink socket owner destruction

 net/wireless/nl80211.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)
