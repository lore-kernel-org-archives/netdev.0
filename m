From: Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v2 0/3] Mesh mpm fixes and enhancements
Date: Wed, 13 Jul 2016 14:44:06 +0300
Message-ID: <20160713114406.24615-1-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>
To: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch set is addressing some issues found in the current 802.11s implementation, specifically when using hostap mpm. 
It's aligning the beacon format and handling some corner cases.

V2 - Updated patches following review comments.
   - Remove unneccary patches (already upsteamed)

Maital Hahn (1):
  mac80211: mesh: flush stations before beacons are stopped

Yaniv Machani (2):
  mac80211: mesh: improve path resolving time
  mac80211: mesh: fixed HT ies in beacon template

 net/mac80211/mesh.c      | 43 ++++++++++++++++++++++++++++++++++++++-----
 net/mac80211/mesh_hwmp.c | 42 +++++++++++++++++++++++++-----------------
 net/mac80211/util.c      |  3 ---
 3 files changed, 63 insertions(+), 25 deletions(-)

-- 
2.9.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
