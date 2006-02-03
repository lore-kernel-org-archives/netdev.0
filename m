From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] net/ipv4/fib_rules.c: make struct fib_rules static again
Date: Fri, 3 Feb 2006 22:02:48 +0100
Message-ID: <20060203210248.GK4408@stusta.de>
References: <20060203000704.3964a39f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030238AbWBCVCw@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>,
	Robert Olsson <robert.olsson@its.uu.se>, davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <20060203000704.3964a39f.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 03, 2006 at 12:07:04AM -0800, Andrew Morton wrote:
>...
> Changes since 2.6.15-mm4:
>...
>  git-net.patch
>...
>  Git trees
>...

struct fib_rules became global for no good reason.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.16-rc1-mm5-full/net/ipv4/fib_rules.c.old	2006-02-03 16:12:48.000000000 +0100
+++ linux-2.6.16-rc1-mm5-full/net/ipv4/fib_rules.c	2006-02-03 16:13:00.000000000 +0100
@@ -100,7 +100,7 @@
 	.r_action =	RTN_UNICAST,
 };
 
-struct hlist_head fib_rules;
+static struct hlist_head fib_rules;
 
 /* writer func called from netlink -- rtnl_sem hold*/
 
