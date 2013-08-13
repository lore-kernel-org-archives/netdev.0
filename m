From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 3/3 v2] ipv6: fix checkpatch errors in net/ipv6/addrconf.c
Date: Tue, 13 Aug 2013 15:57:36 +0800
Message-ID: <5209E6F0.6030407@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:38787 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118Ab3HMIGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 04:06:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ERROR: code indent should use tabs where possible
+^I                idev->cnf.dad_transmits *$

ERROR: code indent should use tabs where possible
+^I                idev->nd_parms->retrans_time / HZ;$

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/ipv6/addrconf.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 2333fa7..08dd643 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1094,8 +1094,8 @@ retry:
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
