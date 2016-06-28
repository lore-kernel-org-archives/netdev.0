From: Yaniv Machani <yanivma@ti.com>
Subject: [PATCH 0/4] Mesh mpm fixes and enhancements
Date: Tue, 28 Jun 2016 14:13:03 +0300
Message-ID: <20160628111307.8784-1-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yaniv Machani <yanivma@ti.com>
To: <linux-kernel@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S . Miller" <davem@davemloft.net>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([198.47.19.11]:56626 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158AbcF1LKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 07:10:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set is addressing some issues found in the current 802.11s implementation,
specifically when using hostap mpm. 
It's aligning the beacon format and handling some corner cases.

Maital Hahn (2):
  mac80211: mesh: flush stations before beacons are stopped
  mac80211/cfg: mesh: fix healing time when a mesh peer is disconnecting

Meirav Kama (2):
  mac80211: mesh: fixed HT ies in beacon template
  mac80211: sta_info: max_peers reached falsely

 net/mac80211/cfg.c       |  1 +
 net/mac80211/mesh.c      | 46 ++++++++++++++++++++++++++++++++++++++++------
 net/mac80211/mesh_hwmp.c | 42 +++++++++++++++++++++++++-----------------
 net/mac80211/sta_info.c  | 14 ++++++++++++++
 net/mac80211/util.c      |  3 ---
 net/wireless/mesh.c      |  2 +-
 6 files changed, 81 insertions(+), 27 deletions(-)

-- 
2.9.0
