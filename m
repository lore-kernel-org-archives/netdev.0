From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2016-09-13
Date: Tue, 13 Sep 2016 22:03:23 +0200
Message-ID: <1473797004-24158-1-git-send-email-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:39795 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1760024AbcIMUDb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 16:03:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

We found a few more issues, I'm sending you small fixes here. The diffstat
would be even shorter, but one of Felix's patches has to move about 30 lines
of code, which makes it seem much bigger than it really is.

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit 15543692a010192b4264ade0d45390e8bb3dc639:

  Merge tag 'mac80211-for-davem-2016-08-30' of git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211 (2016-08-30 21:34:48 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2016-09-13

for you to fetch changes up to ad5987b47e96a0fb6d13fea250e936aed000093c:

  nl80211: validate number of probe response CSA counters (2016-09-13 20:19:27 +0200)

----------------------------------------------------------------
A few more fixes:
 * better mesh path fixing, from Thomas
 * fix TIM IE recalculation after sending frames
   to a sleeping station, from Felix
 * fix sequence number assignment while sending
   frames to a sleeping station, also from Felix
 * validate number of probe response CSA counter
   offsets, fixing a copy/paste bug (from myself)

----------------------------------------------------------------
Felix Fietkau (2):
      mac80211: fix tim recalculation after PS response
      mac80211: fix sequence number assignment for PS response frames

Johannes Berg (1):
      nl80211: validate number of probe response CSA counters

Pedersen, Thomas (1):
      mac80211: make mpath path fixing more robust

 net/mac80211/mesh_hwmp.c    |  3 ++-
 net/mac80211/mesh_pathtbl.c |  2 +-
 net/mac80211/sta_info.c     |  4 +--
 net/mac80211/tx.c           | 65 +++++++++++++++++++++++----------------------
 net/wireless/nl80211.c      |  2 +-
 5 files changed, 39 insertions(+), 37 deletions(-)
