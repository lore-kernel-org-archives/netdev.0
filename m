From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] netfilter: Remove the spurious \ in __ip_vs_lblc_init
Date: Mon, 19 Nov 2012 07:26:30 -0800
Message-ID: <87zk2d7gwp.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:40801 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752735Ab2KSP0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 10:26:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In (464dc801c76a net: Don't export sysctls to unprivileged users)
I typoed and introduced a spurious backslash.  Delete it.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_lblc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index d742aa9..fdd89b9 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -574,7 +574,7 @@ static int __net_init __ip_vs_lblc_init(struct net *net)
 		register_net_sysctl(net, "net/ipv4/vs", ipvs->lblc_ctl_table);
 	if (!ipvs->lblc_ctl_header) {
 		if (!net_eq(net, &init_net))
-			kfree(ipvs->lblc_ctl_table);\
+			kfree(ipvs->lblc_ctl_table);
 		return -ENOMEM;
 	}
 
-- 
1.7.5.4
