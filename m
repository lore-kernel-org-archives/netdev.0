From: pablo@netfilter.org
Subject: [PATCH 05/21] netfilter: nf_ct_snmp: add include file
Date: Fri, 25 Jan 2013 14:54:37 +0100
Message-ID: <1359122093-3404-6-git-send-email-pablo@netfilter.org>
References: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: stephen hemminger <shemminger@vyatta.com>

Prototype for nf_nat_snmp_hook is in nf_conntrack_snmp.h therefore
it should be included to get type checking. Found by sparse.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_snmp.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nf_conntrack_snmp.c b/net/netfilter/nf_conntrack_snmp.c
index 6e545e2..87b95a2 100644
--- a/net/netfilter/nf_conntrack_snmp.c
+++ b/net/netfilter/nf_conntrack_snmp.c
@@ -16,6 +16,7 @@
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_expect.h>
+#include <linux/netfilter/nf_conntrack_snmp.h>
 
 #define SNMP_PORT	161
 
-- 
1.7.10.4

