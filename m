From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH 2/3] netlabel: Fix compiler warnings in netlabel_mgmt.c
Date: Thu, 30 Oct 2008 13:10:25 -0400
Message-ID: <20081030171025.11396.86498.stgit@flek.lan>
References: <20081030170736.11396.46099.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:47054 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758025AbYJ3RK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 13:10:27 -0400
Received: from g1t0039.austin.hp.com (g1t0039.austin.hp.com [16.236.32.45])
	by g5t0009.atlanta.hp.com (Postfix) with ESMTP id D895D30284
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 17:10:26 +0000 (UTC)
In-Reply-To: <20081030170736.11396.46099.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the compiler warnings below, thanks to Andrew Morton for finding them.

 net/netlabel/netlabel_mgmt.c: In function `netlbl_mgmt_listentry':
 net/netlabel/netlabel_mgmt.c:268: warning: 'ret_val' might be used
  uninitialized in this function

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 net/netlabel/netlabel_mgmt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index ee769ec..0a0ef17 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -265,7 +265,7 @@ add_failure:
 static int netlbl_mgmt_listentry(struct sk_buff *skb,
 				 struct netlbl_dom_map *entry)
 {
-	int ret_val;
+	int ret_val = 0;
 	struct nlattr *nla_a;
 	struct nlattr *nla_b;
 	struct netlbl_af4list *iter4;

