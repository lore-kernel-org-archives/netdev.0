From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ebtables: remove unneeded initializations
Date: Mon, 9 Feb 2009 08:24:19 -0800
Message-ID: <20090209082419.064bb842@extreme>
References: <20090204001202.724266235@vyatta.com>
	<20090204001755.685385465@vyatta.com>
	<49904DB3.60004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49904DB3.60004@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The initialization of the lock element is not needed
since the lock is always initialized in ebt_register_table.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/bridge/netfilter/ebtable_broute.c |    1 -
 net/bridge/netfilter/ebtable_filter.c |    1 -
 net/bridge/netfilter/ebtable_nat.c    |    1 -
 3 files changed, 3 deletions(-)

--- a/net/bridge/netfilter/ebtable_broute.c	2009-02-02 15:06:29.824499691 -0800
+++ b/net/bridge/netfilter/ebtable_broute.c	2009-02-02 15:06:39.925749434 -0800
@@ -46,7 +46,6 @@ static struct ebt_table broute_table =
 	.name		= "broute",
 	.table		= &initial_table,
 	.valid_hooks	= 1 << NF_BR_BROUTING,
-	.lock		= __RW_LOCK_UNLOCKED(broute_table.lock),
 	.check		= check,
 	.me		= THIS_MODULE,
 };
--- a/net/bridge/netfilter/ebtable_filter.c	2009-02-02 15:06:29.800254518 -0800
+++ b/net/bridge/netfilter/ebtable_filter.c	2009-02-02 15:06:39.925749434 -0800
@@ -55,7 +55,6 @@ static struct ebt_table frame_filter =
 	.name		= "filter",
 	.table		= &initial_table,
 	.valid_hooks	= FILTER_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(frame_filter.lock),
 	.check		= check,
 	.me		= THIS_MODULE,
 };
--- a/net/bridge/netfilter/ebtable_nat.c	2009-02-02 15:06:29.808250256 -0800
+++ b/net/bridge/netfilter/ebtable_nat.c	2009-02-02 15:06:39.925749434 -0800
@@ -55,7 +55,6 @@ static struct ebt_table frame_nat =
 	.name		= "nat",
 	.table		= &initial_table,
 	.valid_hooks	= NAT_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(frame_nat.lock),
 	.check		= check,
 	.me		= THIS_MODULE,
 };
