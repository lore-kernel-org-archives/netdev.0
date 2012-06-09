From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH] net/core: fix kernel-doc warnings
Date: Fri, 08 Jun 2012 17:01:44 -0700
Message-ID: <4FD29268.1010604@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy6-pub.bluehost.com ([67.222.54.6]:38749 "HELO
	oproxy6-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752774Ab2FIAB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 20:01:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@xenotime.net>

Fix kernel-doc warnings in net/core:

Warning(net/core/skbuff.c:3368): No description found for parameter 'delta_truesize'
Warning(net/core/filter.c:628): No description found for parameter 'pfp'
Warning(net/core/filter.c:628): Excess function parameter 'sk' description in 'sk_unattached_filter_create'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 net/core/filter.c |    4 ++--
 net/core/skbuff.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

--- lnx-35-rc1.orig/net/core/filter.c
+++ lnx-35-rc1/net/core/filter.c
@@ -616,9 +616,9 @@ static int __sk_prepare_filter(struct sk
 /**
  *	sk_unattached_filter_create - create an unattached filter
  *	@fprog: the filter program
- *	@sk: the socket to use
+ *	@pfp: the unattached filter that is created
  *
- * Create a filter independent ofr any socket. We first run some
+ * Create a filter independent of any socket. We first run some
  * sanity checks on it to make sure it does not explode on us later.
  * If an error occurs or there is insufficient memory for the filter
  * a negative errno code is returned. On success the return is zero.
--- lnx-35-rc1.orig/net/core/skbuff.c
+++ lnx-35-rc1/net/core/skbuff.c
@@ -3361,7 +3361,7 @@ EXPORT_SYMBOL(kfree_skb_partial);
  * @to: prior buffer
  * @from: buffer to add
  * @fragstolen: pointer to boolean
- *
+ * @delta_truesize: how much more was allocated than was requested
  */
 bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 		      bool *fragstolen, int *delta_truesize)
