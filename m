From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] netfilter: Resolve missing-field-initializers warnings
Date: Fri, 25 Jul 2014 02:18:56 -0700
Message-ID: <1406279936-6494-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36666 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751220AbaGYJTI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2014 05:19:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Resolve missing-field-initializers warnings by avoiding
implicit inner field initializer. The more explicit form
avoids the warning.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 net/netfilter/xt_set.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
index 80c2e2d..2671cc2 100644
--- a/net/netfilter/xt_set.c
+++ b/net/netfilter/xt_set.c
@@ -43,7 +43,7 @@ struct ip_set_adt_opt n = {		\
 	.dim = d,			\
 	.flags = fs,			\
 	.cmdflags = cfs,		\
-	.ext.timeout = t,		\
+	.ext = { .timeout = t }		\
 }
 
 /* Revision 0 interface: backward compatible with netfilter/iptables */
-- 
1.9.3
