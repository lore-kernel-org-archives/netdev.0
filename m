From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] cfg80211: update comment for locking
Date: Tue, 24 Apr 2007 11:22:36 +0200
Message-ID: <1177406557.3528.19.camel@johannes.berg>
References: <20070423183334.GC5883@tuxdriver.com>
	 <20070423183443.GD5883@tuxdriver.com> <20070423183634.GE5883@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:36641 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754612AbXDXJTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 05:19:40 -0400
In-Reply-To: <20070423183634.GE5883@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a comment that was part of my rtnl locking patch for
cfg80211 but which I forgot for the merge.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
 include/net/cfg80211.h |    4 ++++
 1 file changed, 4 insertions(+)

--- net-2.6.22.orig/include/net/cfg80211.h	2007-04-24 11:20:47.538813880 +0200
+++ net-2.6.22/include/net/cfg80211.h	2007-04-24 11:21:26.388813880 +0200
@@ -23,6 +23,10 @@ struct wiphy;
  * All callbacks except where otherwise noted should return 0
  * on success or a negative error code.
  *
+ * All operations are currently invoked under rtnl for consistency with the
+ * wireless extensions but this is subject to reevaluation as soon as this
+ * code is used more widely and we have a first user without wext.
+ *
  * @add_virtual_intf: create a new virtual interface with the given name
  *
  * @del_virtual_intf: remove the virtual interface determined by ifindex.


