From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 2/3] igmp: export symbol ip_mc_leave_group
Date: Mon, 24 Sep 2012 11:43:06 -0700
Message-ID: <20120924185050.092663403@vyatta.com>
References: <20120924184304.727711327@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>,
	Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:44012 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757570Ab2IXSwu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 14:52:50 -0400
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
