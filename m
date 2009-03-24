From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 05/41: ebtables: remove unneeded initializations
Date: Tue, 24 Mar 2009 15:03:13 +0100 (MET)
Message-ID: <20090324140309.31401.89720.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 842bff366b536787b88c07cbf2416e2cb26cae67
Author: Stephen Hemminger <shemminger@vyatta.com>
Date:   Wed Feb 18 16:30:38 2009 +0100

    netfilter: ebtables: remove unneeded initializations
    
    The initialization of the lock element is not needed
    since the lock is always initialized in ebt_register_table.
    
    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/bridge/netfilter/ebtable_broute.c b/net/bridge/netfilter/ebtable_broute.c
index 8604dfc..c751111 100644
--- a/net/bridge/netfilter/ebtable_broute.c
+++ b/net/bridge/netfilter/ebtable_broute.c
@@ -46,7 +46,6 @@ static struct ebt_table broute_table =
 	.name		= "broute",
 	.table		= &initial_table,
 	.valid_hooks	= 1 << NF_BR_BROUTING,
-	.lock		= __RW_LOCK_UNLOCKED(broute_table.lock),
 	.check		= check,
 	.me		= THIS_MODULE,
 };
diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index 2b2e804..a5eea72 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -55,7 +55,6 @@ static struct ebt_table frame_filter =
 	.name		= "filter",
 	.table		= &initial_table,
 	.valid_hooks	= FILTER_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(frame_filter.lock),
 	.check		= check,
 	.me		= THIS_MODULE,
 };
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index 3fe1ae8..6024c55 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -55,7 +55,6 @@ static struct ebt_table frame_nat =
 	.name		= "nat",
 	.table		= &initial_table,
 	.valid_hooks	= NAT_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(frame_nat.lock),
 	.check		= check,
 	.me		= THIS_MODULE,
 };
