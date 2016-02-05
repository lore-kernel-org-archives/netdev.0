From: Cedric DEBARGE <cedric.debarge@acksys.fr>
Subject: [RFC 0/2] mac80211: add support for ht_caps mcs rxmask override
Date: Fri,  5 Feb 2016 16:41:58 +0100
Message-ID: <cover.1454685673.git.cedric.debarge@acksys.fr>
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Cedric DEBARGE <cedric.debarge@acksys.fr>
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out05.msg.oleane.net ([62.161.7.3]:42580 "EHLO
	smtp-out05.msg.oleane.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833AbcBESLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 13:11:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset allows the ht_caps mcs rxmask to be defined on the fly.
It applies the given rxmask to all available bands.

This is actually limited to radio cards without internal rc.

Cedric DEBARGE (2):
  cfg80211: add support for ht_caps mcs rxmask override
  nl80211: add nl attribute to set ht_caps mcs rxmask override

 include/net/cfg80211.h       |  7 ++++++
 include/uapi/linux/nl80211.h |  5 +++++
 net/mac80211/cfg.c           | 48 +++++++++++++++++++++++++++++++++++++++
 net/mac80211/main.c          | 53 +++++++++++++++++++++++++++++++++++++-------
 net/wireless/nl80211.c       | 18 +++++++++++++++
 net/wireless/rdev-ops.h      | 11 +++++++++
 net/wireless/trace.h         | 15 +++++++++++++
 7 files changed, 149 insertions(+), 8 deletions(-)

-- 
1.9.1
