From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: [PATCH] mac80211: Fix missing kernel-doc notation
Date: Sun, 22 Nov 2009 13:47:58 +0530
Message-ID: <1258877878.4495.50.camel__25849.9915632003$1258878070$gmane$org@ht.satnam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless@vge
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:49181 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753742AbZKVITq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Nov 2009 03:19:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Fix the following htmldocs warnings:

  Warning(net/mac80211/sta_info.h:322): No description found for parameter 'drv_unblock_wk'
  Warning(net/mac80211/sta_info.h:322): No description found for parameter 'drv_unblock_wk'

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: John W. Linville <linville@tuxdriver.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>
Cc: David Miller <davem@davemloft.net>
---
 net/mac80211/sta_info.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index 4c84c22..b4810f6 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -185,6 +185,7 @@ struct sta_ampdu_mlme {
  * @lock: used for locking all fields that require locking, see comments
  *	in the header file.
  * @flaglock: spinlock for flags accesses
+ * @drv_unblock_wk: used for driver PS unblocking
  * @listen_interval: listen interval of this station, when we're acting as AP
  * @pin_status: used internally for pinning a STA struct into memory
  * @flags: STA flags, see &enum ieee80211_sta_info_flags
@@ -225,7 +226,6 @@ struct sta_ampdu_mlme {
  * @debugfs: debug filesystem info
  * @sta: station information we share with the driver
  * @dead: set to true when sta is unlinked
- * @drv_unblock_wk used for driver PS unblocking
  */
 struct sta_info {
 	/* General information, mostly static */
-- 
1.6.5.3


