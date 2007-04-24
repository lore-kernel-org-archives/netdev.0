From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH] cfg80211: update comment for locking
Date: Tue, 24 Apr 2007 16:28:56 -0400
Message-ID: <20070424202856.GH22681@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds a comment that was part of my rtnl locking patch for
cfg80211 but which I forgot for the merge.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
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

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
