From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2016-07-06
Date: Wed,  6 Jul 2016 14:27:43 +0200
Message-ID: <1467808064-5312-1-git-send-email-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:40233 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751201AbcGFM1y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2016 08:27:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

People found two more bugs, so I have two more fixes. Both are related to
memory - one's a leak, the other is a missing allocation failure check.

These are both tagged for stable already, and shouldn't conflict with any
other patches, so if they won't go in any more it won't be a big deal.

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit c041778c966c92c964033f1cdfee60a9f2b5e465:

  cfg80211: fix proto in ieee80211_data_to_8023 for frames without LLC header (2016-06-29 11:50:33 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2016-07-06

for you to fetch changes up to 16a910a6722b7a8680409e634c7c0dac073c01e4:

  cfg80211: handle failed skb allocation (2016-07-06 13:52:18 +0200)

----------------------------------------------------------------
Two more fixes:
 * handle allocation failures in new(ish) A-MSDU decapsulation
 * don't leak memory on nl80211 ACL parse errors

----------------------------------------------------------------
Gregory Greenman (1):
      cfg80211: handle failed skb allocation

Purushottam Kushwaha (1):
      nl80211: Move ACL parsing later to avoid a possible memory leak

 net/wireless/nl80211.c | 8 ++++----
 net/wireless/util.c    | 2 ++
 2 files changed, 6 insertions(+), 4 deletions(-)
