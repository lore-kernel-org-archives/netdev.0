From: Adrian Bunk <bunk@kernel.org>
Subject: [-mm patch] make tcp_splice_data_recv() static
Date: Sun, 9 Sep 2007 22:25:58 +0200
Message-ID: <20070909202558.GZ3563@stusta.de>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:60762 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759392AbXIIUZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Sep 2007 16:25:51 -0400
Content-Disposition: inline
In-Reply-To: <20070831215822.26e1432b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 31, 2007 at 09:58:22PM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.23-rc3-mm1:
>...
>  git-block.patch
>...
>  git trees
>...

tcp_splice_data_recv() can become static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
233aefd2a215430c16bd02eca06fb8a4b6079f7a 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 22576e4..6623796 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -515,8 +515,9 @@ static inline void tcp_push(struct sock *sk, int flags, int mss_now,
 	}
 }
 
-int tcp_splice_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb,
-			 unsigned int offset, size_t len)
+static int tcp_splice_data_recv(read_descriptor_t *rd_desc,
+				struct sk_buff *skb,
+				unsigned int offset, size_t len)
 {
 	struct tcp_splice_state *tss = rd_desc->arg.data;
 

