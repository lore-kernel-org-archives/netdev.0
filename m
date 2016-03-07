From: Wei Tang <tangwei@cmss.chinamobile.com>
Subject: [PATCH] netlabel: do not initialise statics to NULL
Date: Mon,  7 Mar 2016 14:29:53 +0800
Message-ID: <1457332193-3182-1-git-send-email-tangwei@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, Wei Tang <tangwei@cmss.chinamobile.com>
To: paul@paul-moore.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from n9-45.mail.139.com ([221.176.9.45]:56417 "EHLO
	n9-45.mail.139.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357AbcCGGkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 01:40:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the checkpatch.pl error to netlabel_domainhash.c:

ERROR: do not initialise statics to NULL

Signed-off-by: Wei Tang <tangwei@cmss.chinamobile.com>
---
 net/netlabel/netlabel_domainhash.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index f0cb92f..ada6742 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -55,8 +55,8 @@ struct netlbl_domhsh_tbl {
 static DEFINE_SPINLOCK(netlbl_domhsh_lock);
 #define netlbl_domhsh_rcu_deref(p) \
 	rcu_dereference_check(p, lockdep_is_held(&netlbl_domhsh_lock))
-static struct netlbl_domhsh_tbl *netlbl_domhsh = NULL;
-static struct netlbl_dom_map *netlbl_domhsh_def = NULL;
+static struct netlbl_domhsh_tbl *netlbl_domhsh;
+static struct netlbl_dom_map *netlbl_domhsh_def;
 
 /*
  * Domain Hash Table Helper Functions
-- 
1.9.1
