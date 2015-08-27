From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net-next 2/2] openvswitch: Include ip6_fib.h.
Date: Thu, 27 Aug 2015 15:25:46 -0700
Message-ID: <1440714346-43304-3-git-send-email-joestringer@nicira.com>
References: <1440714346-43304-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pshelar@nicira.com,
	pablo@netfilter.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440714346-43304-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kbuild test robot reports that certain configurations will not
automatically pick up on the "struct rt6_info" definition, so explicitly
include the header for this structure.

Fixes: 7f8a436 "openvswitch: Add conntrack action"
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 net/openvswitch/actions.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 736a113..4487543 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -33,6 +33,7 @@
 #include <net/dst.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
+#include <net/ip6_fib.h>
 #include <net/checksum.h>
 #include <net/dsfield.h>
 #include <net/mpls.h>
-- 
2.1.4
