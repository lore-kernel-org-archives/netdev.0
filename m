From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2015-08-14
Date: Fri, 14 Aug 2015 13:20:26 +0200
Message-ID: <1439551226.2091.13.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:54743 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754917AbbHNLUa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2015 07:20:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I'm back from vacation, and found a single bugfix waiting. It's in this
pull request, but I'm not quite up to speed as to what's happening with
the release. If it goes in, great; if not I've already tagged it with
Cc stable anyway.

Thanks,
johannes



The following changes since commit 923b352f19d9ea971ae2536eab55f5fc9e95fedf:

  cfg80211: use RTNL locked reg_can_beacon for IR-relaxation (2015-07-17 15:02:02 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2015-08-14

for you to fetch changes up to f5eeb5fa191fd7b634cbc4883ac58f3b2184dbc5:

  mac80211: fix invalid read in minstrel_sort_best_tp_rates() (2015-08-13 13:52:34 +0200)

----------------------------------------------------------------
We have a single bugfix for an invalid memory read.

----------------------------------------------------------------
Adrien Schildknecht (1):
      mac80211: fix invalid read in minstrel_sort_best_tp_rates()

 net/mac80211/rc80211_minstrel.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)
