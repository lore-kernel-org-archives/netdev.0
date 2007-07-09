From: akpm@linux-foundation.org
Subject: [patch 6/8] net: make struct dccp_li_cachep static
Date: Mon, 09 Jul 2007 11:51:12 -0700
Message-ID: <200707091851.l69IpD9p001740@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, bunk@stusta.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43956 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757692AbXGISvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 14:51:53 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/dccp/ccids/lib/loss_interval.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/dccp/ccids/lib/loss_interval.c~net-make-struct-dccp_li_cachep-static net/dccp/ccids/lib/loss_interval.c
--- a/net/dccp/ccids/lib/loss_interval.c~net-make-struct-dccp_li_cachep-static
+++ a/net/dccp/ccids/lib/loss_interval.c
@@ -27,7 +27,7 @@ struct dccp_li_hist_entry {
 	u32		 dccplih_interval;
 };
 
-struct kmem_cache *dccp_li_cachep __read_mostly;
+static struct kmem_cache *dccp_li_cachep __read_mostly;
 
 static inline struct dccp_li_hist_entry *dccp_li_hist_entry_new(const gfp_t prio)
 {
_
