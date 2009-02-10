From: Chuck Ebbert <cebbert@redhat.com>
Subject: [patch] pkt_sched: type should be __u32 in header
Date: Tue, 10 Feb 2009 15:26:23 -0500
Message-ID: <20090210152623.79149e13@dhcp-100-2-144.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58422 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755122AbZBJU2y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Feb 2009 15:28:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using u32 in this header breaks the build of iptables.

Signed-off-by: Chuck Ebbert <cebbert@redhat.com>

Index: linux-2.6.28.noarch/include/linux/pkt_sched.h
===================================================================
--- linux-2.6.28.noarch.orig/include/linux/pkt_sched.h
+++ linux-2.6.28.noarch/include/linux/pkt_sched.h
@@ -515,7 +515,7 @@ enum
 
 struct tc_drr_stats
 {
-	u32	deficit;
+	__u32	deficit;
 };
 
 #endif
