From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 0/2] bcm43xx-d80211: fixes after d80211 update
Date: Tue, 18 Jul 2006 17:51:05 +0200 (CEST)
Message-ID: <20060718175044.204144808.midnight@suse.cz>
Cc: netdev@vger.kernel.org, Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:25831 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932290AbWGRPtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 11:49:17 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both patches were acked by Michael. They allow bcm43xx-d80211 to take
advantage of d80211 update.

You may also pull them from 'bcm43xx' branch of my tree:
git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git bcm43xx


Jiri Benc:
      bcm43xx-d80211: use host_gen_beacon_template
      bcm43xx-d80211: use SET_NETDEV_DEV

 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |   37 ++++++------------
 include/net/d80211.h                               |    6 +--
 include/net/d80211_mgmt.h                          |   42 ++++++++++----------
 net/d80211/ieee80211_sta.c                         |    7 +++
 4 files changed, 42 insertions(+), 50 deletions(-)

-- 
Jiri Benc
SUSE Labs
