From: Dave Jones <davej@redhat.com>
Subject: compile fix for ip6mr.c
Date: Fri, 30 Jan 2009 21:33:57 -0500
Message-ID: <20090131023357.GA16406@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml@gelk.kernelslacker.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38621 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752137AbZAaCeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 21:34:00 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n0V2XxZ2011892
	for <netdev@vger.kernel.org>; Fri, 30 Jan 2009 21:33:59 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n0V2XxrA017792
	for <netdev@vger.kernel.org>; Fri, 30 Jan 2009 21:33:59 -0500
Received: from gelk.kernelslacker.org (vpn-12-68.rdu.redhat.com [10.11.12.68])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n0V2XxHt001222
	for <netdev@vger.kernel.org>; Fri, 30 Jan 2009 21:33:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/ipv6/ip6mr.c: In function 'pim6_rcv':
net/ipv6/ip6mr.c:368: error: implicit declaration of function 'csum_ipv6_magic'

Signed-off-by: Dave Jones <davej@redhat.com>

--- linux-2.6.28.noarch/net/ipv6/ip6mr.c~	2009-01-30 21:32:19.000000000 -0500
+++ linux-2.6.28.noarch/net/ipv6/ip6mr.c	2009-01-30 21:32:29.000000000 -0500
@@ -48,6 +48,7 @@
 #include <linux/pim.h>
 #include <net/addrconf.h>
 #include <linux/netfilter_ipv6.h>
+#include <net/ip6_checksum.h>
 
 /* Big lock, protecting vif table, mrt cache and mroute socket state.
    Note that the changes are semaphored via rtnl_lock.
-- 
http://www.codemonkey.org.uk
