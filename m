From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2017-03-16
Date: Thu, 16 Mar 2017 10:51:55 +0100
Message-ID: <20170316095156.31253-1-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:41700 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751763AbdCPJwD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Mar 2017 05:52:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here's the pull request you were waiting for. I went through all my
pending patches but only this one is applicable for net.git at this
time, so it's just a single one.

Since I didn't have a current base, I forwarded to net.git first
and re-validated the patch there, but you might might have to be
careful if you merge to not fast-fwd on your side (though, even
if you do that, I don't think it matters much).

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 22a0e18eac7a9e986fec76c60fa4a2926d1291e2:

  net: properly release sk_frag.page (2017-03-15 15:37:45 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-03-16

for you to fetch changes up to ea90e0dc8cecba6359b481e24d9c37160f6f524f:

  nl80211: fix dumpit error path RTNL deadlocks (2017-03-16 10:30:03 +0100)

----------------------------------------------------------------
Just a single fix, for the RTNL locking issues.

----------------------------------------------------------------
Johannes Berg (1):
      nl80211: fix dumpit error path RTNL deadlocks

 net/wireless/nl80211.c | 127 ++++++++++++++++++++++---------------------------
 1 file changed, 56 insertions(+), 71 deletions(-)
