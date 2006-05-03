From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 0/3] d80211: bugfixes, reducing number of interfaces (again)
Date: Wed,  3 May 2006 17:11:27 +0200 (CEST)
Message-ID: <20060503171031.304543000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:43136 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965214AbWECPKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 11:10:49 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Following patches can be also obtained from:
git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git up

Jiri Benc:
      d80211: get rid of default management interface
      d80211: use alloc_netdev
      d80211: fix is_ieee80211_device

 net/d80211/ieee80211.c       |  150 +++++++++++++++++++------------------------
 net/d80211/ieee80211_i.h     |   10 +-
 net/d80211/ieee80211_iface.c |  104 ++++++++++++++++++++++-------
 3 files changed, 152 insertions(+), 112 deletions(-)

-- 
Jiri Benc
SUSE Labs
