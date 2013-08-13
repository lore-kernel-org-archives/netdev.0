From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 2/2] ipv6: fix checkpatch errors in net/ipv6/addrconf.c
Date: Tue, 13 Aug 2013 14:15:08 +0800
Message-ID: <5209CEEC.2050505@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:21223 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753187Ab3HMGPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 02:15:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ERROR: Macros with complex values should be enclosed in parenthesis
+#define ADBG(x) printk x

ERROR: code indent should use tabs where possible
+^I                idev->cnf.dad_transmits *$

ERROR: code indent should use tabs where possible
+^I                idev->nd_parms->retrans_time / HZ;$

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/ipv6/addrconf.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 99f9fd5..5aaf931 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -99,7 +99,7 @@
 #define ACONF_DEBUG 2
 
 #if ACONF_DEBUG >= 3
-#define ADBG(x) printk x
+#define ADBG(x) (printk x)
 #else
 #define ADBG(x)
 #endif
@@ -1105,8 +1105,8 @@ retry:
 	spin_unlock_bh(&ifp->lock);
 
 	regen_advance = idev->cnf.regen_max_retry *
-	                idev->cnf.dad_transmits *
-	                idev->nd_parms->retrans_time / HZ;
+			idev->cnf.dad_transmits *
+			idev->nd_parms->retrans_time / HZ;
 	write_unlock(&idev->lock);
 
 	/* A temporary address is created only if this calculated Preferred
-- 
1.8.2.1
