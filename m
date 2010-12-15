From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH 3/3] wireless:mac80211: kill unuse macro MESH_CFG_CMP_LEN
 in mesh.h
Date: Wed, 15 Dec 2010 14:27:28 +0800
Message-ID: <4D085FD0.4020804@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	Network-Maillist <netdev@vger.kernel.org>
To: johannes@sipsolutions.net, linville@tuxdriver.com,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60155 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752886Ab0LOG3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 01:29:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 00d3f14c has removed the references of this macro,
but left it only. So remove this definition.


commit 00d3f14cf9f12c21428121026a5e1d5f65926447
Author: Johannes Berg <johannes@sipsolutions.net>
Date:   Tue Feb 10 21:26:00 2009 +0100

    mac80211: use cfg80211s BSS infrastructure
    
    Remove all the code from mac80211 to keep track of BSSes
    and use the cfg80211-provided code completely.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/mac80211/mesh.h |   12 ------------
 1 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/net/mac80211/mesh.h b/net/mac80211/mesh.h
index 58e7411..8111c64 100644
--- a/net/mac80211/mesh.h
+++ b/net/mac80211/mesh.h
@@ -163,18 +163,6 @@ struct mesh_rmc {
 	u32 idx_mask;
 };
 
-
-/*
- * MESH_CFG_COMP_LEN Includes:
- * 	- Active path selection protocol ID.
- * 	- Active path selection metric ID.
- * 	- Congestion control mode identifier.
- * 	- Channel precedence.
- * Does not include mesh capabilities, which may vary across nodes in the same
- * mesh
- */
-#define MESH_CFG_CMP_LEN 	(IEEE80211_MESH_CONFIG_LEN - 2)
-
 /* Default values, timeouts in ms */
 #define MESH_TTL 		31
 #define MESH_MAX_RETR	 	3
-- 
1.6.3.3
