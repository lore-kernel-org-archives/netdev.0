From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] netlink: fix documentation typo in netlink_set_err()
Date: Tue, 19 Nov 2013 10:35:40 +0100
Message-ID: <1384853740-21404-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:40597 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727Ab3KSJfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 04:35:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

The parameter is just 'group', not 'groups', fix the documentation typo.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/netlink/af_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 8df7f64..f0176e1 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2017,7 +2017,7 @@ out:
  * netlink_set_err - report error to broadcast listeners
  * @ssk: the kernel netlink socket, as returned by netlink_kernel_create()
  * @portid: the PORTID of a process that we want to skip (if any)
- * @groups: the broadcast group that will notice the error
+ * @group: the broadcast group that will notice the error
  * @code: error code, must be negative (as usual in kernelspace)
  *
  * This function returns the number of broadcast listeners that have set the
-- 
1.8.4.rc3
