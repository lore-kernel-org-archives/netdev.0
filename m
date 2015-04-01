From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2015-04-01
Date: Wed, 01 Apr 2015 15:46:09 +0200
Message-ID: <1427895969.3428.9.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:58637 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752117AbbDANqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 09:46:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This morning I randomly ran into a kernel crash and then I looked into
it and came up with this fix. It's clearly been around for quite a while
without anyone having seen it before (to my knowledge), so if you think
you don't want to pull it into net.git at this point that should be
fine.

Let me know what you want to do with it, I can also put it into
mac80211-next instead (although then Greg complains that he gets a lot
of Cc stable patches in rc1, but all the processes need time ...).

Thanks,
johannes


The following changes since commit f84eaa1068315409ffbef57e6fea312180787db3:

  mac80211: ignore CSA to same channel (2015-03-16 09:36:12 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2015-04-01

for you to fetch changes up to 788211d81bfdf9b6a547d0530f206ba6ee76b107:

  mac80211: fix RX A-MPDU session reorder timer deletion (2015-04-01 14:35:01 +0200)

----------------------------------------------------------------
This contains just a single fix for a crash I happened to randomly
run into today during testing. It's clearly been around for a while,
but is pretty hard to trigger, even when I tried explicitly (and
modified the code to make it more likely) it rarely did.

----------------------------------------------------------------
Johannes Berg (1):
      mac80211: fix RX A-MPDU session reorder timer deletion

 net/mac80211/agg-rx.c   | 8 ++++++--
 net/mac80211/rx.c       | 7 ++++---
 net/mac80211/sta_info.h | 2 ++
 3 files changed, 12 insertions(+), 5 deletions(-)
