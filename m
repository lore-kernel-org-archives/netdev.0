From: Wei Tang <tangwei@cmss.chinamobile.com>
Subject: [PATCH] netlink: do not initialise statics to 0 or NULL
Date: Mon,  7 Mar 2016 14:25:10 +0800
Message-ID: <1457331910-3081-1-git-send-email-tangwei@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, Wei Tang <tangwei@cmss.chinamobile.com>
To: paul@paul-moore.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from n9-21.mail.139.com ([221.176.9.21]:40747 "EHLO
	n9-21.mail.139.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357AbcCGGfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 01:35:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the checkpatch.pl error to netlabel_unlabeled.c:

ERROR: do not initialise statics to 0 or NULL

Signed-off-by: Wei Tang <tangwei@cmss.chinamobile.com>
---
 net/netlabel/netlabel_unlabeled.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index b038092..9eaa9a1 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -116,11 +116,11 @@ struct netlbl_unlhsh_walk_arg {
 static DEFINE_SPINLOCK(netlbl_unlhsh_lock);
 #define netlbl_unlhsh_rcu_deref(p) \
 	rcu_dereference_check(p, lockdep_is_held(&netlbl_unlhsh_lock))
-static struct netlbl_unlhsh_tbl *netlbl_unlhsh = NULL;
-static struct netlbl_unlhsh_iface *netlbl_unlhsh_def = NULL;
+static struct netlbl_unlhsh_tbl *netlbl_unlhsh;
+static struct netlbl_unlhsh_iface *netlbl_unlhsh_def;
 
 /* Accept unlabeled packets flag */
-static u8 netlabel_unlabel_acceptflg = 0;
+static u8 netlabel_unlabel_acceptflg;
 
 /* NetLabel Generic NETLINK unlabeled family */
 static struct genl_family netlbl_unlabel_gnl_family = {
-- 
1.9.1
