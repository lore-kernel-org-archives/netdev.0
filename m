From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/3] igmp: export symbol ip_mc_leave_group
Date: Mon, 01 Oct 2012 15:32:34 -0700
Message-ID: <20121001223254.264749157@vyatta.com>
References: <20121001223232.566037595@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:46337 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752688Ab2JAWfI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 18:35:08 -0400
Content-Disposition: inline; filename=igmp-leave.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Needed for VXLAN.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/igmp.c	2012-09-17 17:15:06.747860247 -0700
+++ b/net/ipv4/igmp.c	2012-09-17 17:16:33.554984978 -0700
@@ -1904,6 +1904,7 @@ int ip_mc_leave_group(struct sock *sk, s
 	rtnl_unlock();
 	return ret;
 }
+EXPORT_SYMBOL(ip_mc_leave_group);
 
 int ip_mc_source(int add, int omode, struct sock *sk, struct
 	ip_mreq_source *mreqs, int ifindex)
