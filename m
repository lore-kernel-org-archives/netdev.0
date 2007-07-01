From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] make struct dccp_li_cachep static
Date: Sun, 1 Jul 2007 22:23:44 +0200
Message-ID: <20070701202344.GX10869@stusta.de>
References: <20070628034321.38c9f12b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, acme@ghostprotocols.net,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:46898 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759305AbXGAUXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2007 16:23:17 -0400
Content-Disposition: inline
In-Reply-To: <20070628034321.38c9f12b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 28, 2007 at 03:43:21AM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.22-rc4-mm2:
>...
>  git-net.patch
>...
>  git trees
>...


Struct dccp_li_cachep can become static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---
--- linux-2.6.22-rc6-mm1/net/dccp/ccids/lib/loss_interval.c.old	2007-07-01 00:38:12.000000000 +0200
+++ linux-2.6.22-rc6-mm1/net/dccp/ccids/lib/loss_interval.c	2007-07-01 00:38:21.000000000 +0200
@@ -27,7 +27,7 @@
 	u32		 dccplih_interval;
 };
 
-struct kmem_cache *dccp_li_cachep __read_mostly;
+static struct kmem_cache *dccp_li_cachep __read_mostly;
 
 static inline struct dccp_li_hist_entry *dccp_li_hist_entry_new(const gfp_t prio)
 {

