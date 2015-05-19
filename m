From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211-next 2015-05-19
Date: Tue, 19 May 2015 09:20:39 +0200
Message-ID: <1432020039.7437.0.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:57810 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755286AbbESHUm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 03:20:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

My last pull request introduced two bugs, and we found two more that
were present earlier, so I have four bug fixes now.

Please pull.

Thanks,
Johannes


The following changes since commit bbbe8c8c596b3784a2ed08772900e827f8ba72c5:

  mac80211: add missing documentation for rate_ctrl_lock (2015-05-06 16:00:32 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2015-05-19

for you to fetch changes up to 658358cec93a7130615cfc1d6843ab07e49625e6:

  mac80211: fix throughput LED trigger (2015-05-11 19:16:04 +0200)

----------------------------------------------------------------
This just has a few fixes:
 * LED throughput trigger was crashing
 * fast-xmit wasn't treating QoS changes in IBSS correctly
 * TDLS could use the wrong channel definition
 * using a reserved channel context could use the wrong channel width

----------------------------------------------------------------
Andrei Otcheretianski (1):
      mac80211: adjust reserved chan_ctx when assigned to vif

Arik Nemtsov (1):
      mac80211: TDLS: use the BSS chandef for HT/VHT operation IEs

Johannes Berg (2):
      mac80211: check fast-xmit if IBSS STA QoS changed
      mac80211: fix throughput LED trigger

 net/mac80211/chan.c        |  4 ++++
 net/mac80211/ibss.c        |  5 ++++-
 net/mac80211/ieee80211_i.h |  1 -
 net/mac80211/led.c         | 12 ++++++------
 net/mac80211/tdls.c        | 27 ++++++++-------------------
 5 files changed, 22 insertions(+), 27 deletions(-)
