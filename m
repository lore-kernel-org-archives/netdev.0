From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 0/5] d80211: pull request - fragmentation, fixes
Date: Fri, 23 Jun 2006 15:01:17 +0200 (CEST)
Message-ID: <20060623150047.368594000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:10375 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964797AbWFWM74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 08:59:56 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from
git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git master
to obtain following patches:

Jiri Benc:
      d80211: update tx.skb after TX handler calls
      d80211: per-queue TX flow control
      d80211: handle full queue when sending fragments
      d80211: add first_fragment flag to ieee80211_tx_control

Michael Buesch:
      d80211: allow NULL for control in beacon_get

 include/net/d80211.h     |   32 +++++
 net/d80211/ieee80211.c   |  293 ++++++++++++++++++++++++++++++++++++----------
 net/d80211/ieee80211_i.h |   20 +++
 net/d80211/wme.c         |    9 +
 4 files changed, 285 insertions(+), 69 deletions(-)


-- 
Jiri Benc
SUSE Labs
