From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Subject: [PATCH] remove useless code from fib6_del_route
Date: Fri, 28 Dec 2007 15:12:28 +0800
Message-ID: <4774A1DC.9060308@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55357 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751425AbXL1HMn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2007 02:12:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,
There are useless codes in fib6_del_route(). The following patch
has been tested, every thing looks fine, as usual.

Signed-off-by: Gui Jianfeng<guijianfeng@cn.fujitsu.com>

---
 net/ipv6/ip6_fib.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 946cf38..5f96eb1 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1122,9 +1122,6 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 
 	rt->u.dst.rt6_next = NULL;
 
-	if (fn->leaf == NULL && fn->fn_flags&RTN_TL_ROOT)
-		fn->leaf = &ip6_null_entry;
-
 	/* If it was last route, expunge its radix tree node */
 	if (fn->leaf == NULL) {
 		fn->fn_flags &= ~RTN_RTINFO;
-- 



Regards
Gui Jianfeng
