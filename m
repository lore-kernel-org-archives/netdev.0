From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH iproute2 net-next v1 1/7] tipc: remove dead code
Date: Mon, 12 Sep 2016 17:17:15 +0200
Message-ID: <1473693441-14254-2-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1473693441-14254-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
        <maloy@donjonn.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:61441 "EHLO
        sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932883AbcILPRh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 11:17:37 -0400
In-Reply-To: <1473693441-14254-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

remove dead code and a newline.

Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 tipc/link.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/tipc/link.c b/tipc/link.c
index 061b1c534389..8bdc98224d39 100644
--- a/tipc/link.c
+++ b/tipc/link.c
@@ -90,7 +90,6 @@ static int link_get_cb(const struct nlmsghdr *nlh, void *data)
 	return MNL_CB_OK;
 }
 
-
 static int cmd_link_get_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
 			     struct cmdl *cmdl, void *data)
 {
@@ -475,8 +474,6 @@ static int cmd_link_set_prop(struct nlmsghdr *nlh, const struct cmd *cmd,
 	mnl_attr_nest_end(nlh, attrs);
 
 	return msg_doit(nlh, link_get_cb, &prop);
-
-	return 0;
 }
 
 static int cmd_link_set(struct nlmsghdr *nlh, const struct cmd *cmd,
-- 
2.1.4
