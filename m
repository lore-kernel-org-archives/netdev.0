From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 08/11] tipc: Eliminate useless initialization when creating subscriber
Date: Tue, 30 Nov 2010 17:01:00 -0500
Message-ID: <1291154463-26346-9-git-send-email-paul.gortmaker@windriver.com>
References: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58726 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792Ab0K3WBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 17:01:14 -0500
In-Reply-To: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Removes initialization of a local variable that is always assigned
a different value before it is referenced.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/subscr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index e13c89a..23f43d0 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -542,7 +542,7 @@ static void subscr_named_msg_event(void *usr_handle,
 int tipc_subscr_start(void)
 {
 	struct tipc_name_seq seq = {TIPC_TOP_SRV, TIPC_TOP_SRV, TIPC_TOP_SRV};
-	int res = -1;
+	int res;
 
 	memset(&topsrv, 0, sizeof (topsrv));
 	spin_lock_init(&topsrv.lock);
-- 
1.7.3.2.146.g2d444

