From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 06/10] tipc: remove redundant memset and stale comment from subscr.c
Date: Mon, 30 Apr 2012 18:37:04 -0400
Message-ID: <1335825428-16053-7-git-send-email-paul.gortmaker@windriver.com>
References: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:45985 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757343Ab2D3WhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 18:37:20 -0400
In-Reply-To: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminate code to zero-out the main topology service structure,
which is already zeroed-out.

Get rid of a comment documenting a field of the main topology
service structure that no longer exists.

Both are cosmetic changes with no impact on runtime behaviour.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/subscr.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index b2964e9..af93ea9 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -56,7 +56,6 @@ struct tipc_subscriber {
 
 /**
  * struct top_srv - TIPC network topology subscription service
- * @user_ref: TIPC userid of subscription service
  * @setup_port: reference to TIPC port that handles subscription requests
  * @subscription_count: number of active subscriptions (not subscribers!)
  * @subscriber_list: list of ports subscribing to service
@@ -535,7 +534,6 @@ int tipc_subscr_start(void)
 	struct tipc_name_seq seq = {TIPC_TOP_SRV, TIPC_TOP_SRV, TIPC_TOP_SRV};
 	int res;
 
-	memset(&topsrv, 0, sizeof(topsrv));
 	spin_lock_init(&topsrv.lock);
 	INIT_LIST_HEAD(&topsrv.subscriber_list);
 
-- 
1.7.9.6
