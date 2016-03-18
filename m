From: Luis de Bethencourt <luisbg@osg.samsung.com>
Subject: [PATCH] mac80211: remove description of dropped member
Date: Fri, 18 Mar 2016 19:23:18 +0000
Message-ID: <1458328998-14021-1-git-send-email-luisbg@osg.samsung.com>
Cc: johannes@sipsolutions.net, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Luis de Bethencourt <luisbg@osg.samsung.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:54723 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752038AbcCRTX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2016 15:23:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 976bd9efdae6 ("mac80211: move beacon_loss_count into ifmgd")
removed the member from the sta_info struct but the description stayed
lingering. Remove it.

Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
---
Hi,

A second patch fixing a warning in make htmldocs.

Thanks :)
Luis

 net/mac80211/sta_info.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index 053f5c4..62193f4 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -377,7 +377,6 @@ DECLARE_EWMA(signal, 1024, 8)
  * @uploaded: set to true when sta is uploaded to the driver
  * @sta: station information we share with the driver
  * @sta_state: duplicates information about station state (for debug)
- * @beacon_loss_count: number of times beacon loss has triggered
  * @rcu_head: RCU head used for freeing this station struct
  * @cur_max_bandwidth: maximum bandwidth to use for TX to the station,
  *	taken from HT/VHT capabilities or VHT operating mode notification
-- 
2.5.1
