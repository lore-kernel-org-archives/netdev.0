From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 1/3] genetlink: document parallel_ops
Date: Thu, 15 Jan 2015 12:04:43 +0100
Message-ID: <1421319885-31779-1-git-send-email-johannes@sipsolutions.net>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
	Sedat Dilek <sedat.dilek@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35468 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752604AbbAOLEu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 06:04:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

The kernel-doc for the parallel_ops family struct member is
missing, add it.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/genetlink.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 84125088c309..2ea2c55bdc87 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -27,6 +27,8 @@ struct genl_info;
  * @maxattr: maximum number of attributes supported
  * @netnsok: set to true if the family can handle network
  *	namespaces and should be presented in all of them
+ * @parallel_ops: operations can be called in parallel and aren't
+ *	synchronized by the core genetlink code
  * @pre_doit: called before an operation's doit callback, it may
  *	do additional, common, filtering and return an error
  * @post_doit: called after an operation's doit callback, it may
-- 
2.1.4
