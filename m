From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2015-09-23
Date: Wed, 23 Sep 2015 10:44:14 +0200
Message-ID: <1442997854.1889.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:60107 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753377AbbIWIoS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2015 04:44:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

It's been pretty quiet for this cycle since the sizeof() mess, but I
have two more fixes now I'd like to get in.

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit ef9be10c8c999e00b239eec24cf01952a308f8e7:

  mac80211: reject software RSSI CQM with beacon filtering (2015-09-04 15:23:22 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2015-09-22

for you to fetch changes up to babc305e21ea3811d98b67437299360904ac1b6a:

  mac80211: reset CQM history upon reconfiguration (2015-09-22 15:22:50 +0200)

----------------------------------------------------------------
Just two small fixes:
 * VHT MCS mask array overrun, reported by Dan Carpenter
 * reset CQM history to always get a notification, from Sara Sharon

----------------------------------------------------------------
Johannes Berg (1):
      mac80211: fix VHT MCS mask array overrun

Sara Sharon (1):
      mac80211: reset CQM history upon reconfiguration

 net/mac80211/cfg.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)
