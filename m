From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] net/sched/act_simple.c: make struct simp_hash_info static
Date: Wed, 30 Aug 2006 22:35:07 +0200
Message-ID: <20060830203507.GL18276@stusta.de>
References: <20060826160922.3324a707.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:21508 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1751500AbWH3UfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 16:35:09 -0400
To: Andrew Morton <akpm@osdl.org>, davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <20060826160922.3324a707.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 26, 2006 at 04:09:22PM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.18-rc4-mm2:
>...
>  git-net.patch
>...
>  git trees
>...

This patch makes the needlessly global struct simp_hash_info static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.18-rc4-mm3/net/sched/act_simple.c.old	2006-08-30 20:54:20.000000000 +0200
+++ linux-2.6.18-rc4-mm3/net/sched/act_simple.c	2006-08-30 20:54:43.000000000 +0200
@@ -28,7 +28,7 @@
 static u32 simp_idx_gen;
 static DEFINE_RWLOCK(simp_lock);
 
-struct tcf_hashinfo simp_hash_info = {
+static struct tcf_hashinfo simp_hash_info = {
 	.htab	=	tcf_simp_ht,
 	.hmask	=	SIMP_TAB_MASK,
 	.lock	=	&simp_lock,

