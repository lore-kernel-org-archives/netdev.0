From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 23/29: ip{,6}t_policy.h should include xp_policy.h
Date: Thu, 27 Nov 2008 17:15:34 +0100 (MET)
Message-ID: <20081127161534.13891.33306.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53421 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753571AbYK0QPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 11:15:35 -0500
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 018a7bf1e55000dd792194238c9043918d24d3dd
Author: Andy Whitcroft <apw@canonical.com>
Date:   Thu Nov 20 15:59:56 2008 +0100

    netfilter: ip{,6}t_policy.h should include xp_policy.h
    
    It seems that all of the include/netfilter_{ipv4,ipv6}/{ipt,ip6t}_*.h which
    share constants include the corresponding include/netfilter/xp_*.h files.
    Neither ipt_policy.h not ip6t_policy.h do.  Make these consistant with
    the norm.
    
    Signed-off-by: Andy Whitcroft <apw@canonical.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter_ipv4/ipt_policy.h b/include/linux/netfilter_ipv4/ipt_policy.h
index b9478a2..1037fb2 100644
--- a/include/linux/netfilter_ipv4/ipt_policy.h
+++ b/include/linux/netfilter_ipv4/ipt_policy.h
@@ -1,6 +1,8 @@
 #ifndef _IPT_POLICY_H
 #define _IPT_POLICY_H
 
+#include <linux/netfilter/xt_policy.h>
+
 #define IPT_POLICY_MAX_ELEM		XT_POLICY_MAX_ELEM
 
 /* ipt_policy_flags */
diff --git a/include/linux/netfilter_ipv6/ip6t_policy.h b/include/linux/netfilter_ipv6/ip6t_policy.h
index 6bab316..b1c449d 100644
--- a/include/linux/netfilter_ipv6/ip6t_policy.h
+++ b/include/linux/netfilter_ipv6/ip6t_policy.h
@@ -1,6 +1,8 @@
 #ifndef _IP6T_POLICY_H
 #define _IP6T_POLICY_H
 
+#include <linux/netfilter/xt_policy.h>
+
 #define IP6T_POLICY_MAX_ELEM		XT_POLICY_MAX_ELEM
 
 /* ip6t_policy_flags */
