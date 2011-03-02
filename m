From: kaber@trash.net
Subject: [PATCH 01/13] netfilter: ipset: add dependency on CONFIG_NETFILTER_NETLINK
Date: Wed,  2 Mar 2011 13:12:41 +0100
Message-ID: <1299067973-15977-2-git-send-email-kaber@trash.net>
References: <1299067973-15977-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1299067973-15977-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

When SYSCTL and PROC_FS and NETFILTER_NETLINK are not enabled:

net/built-in.o: In function `try_to_load_type':
ip_set_core.c:(.text+0x3ab49): undefined reference to `nfnl_unlock'
ip_set_core.c:(.text+0x3ab4e): undefined reference to `nfnl_lock'
...

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Acked-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipset/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipset/Kconfig b/net/netfilter/ipset/Kconfig
index 3b970d3..2c5b348 100644
--- a/net/netfilter/ipset/Kconfig
+++ b/net/netfilter/ipset/Kconfig
@@ -1,6 +1,7 @@
 menuconfig IP_SET
 	tristate "IP set support"
 	depends on INET && NETFILTER
+	depends on NETFILTER_NETLINK
 	help
 	  This option adds IP set support to the kernel.
 	  In order to define and use the sets, you need the userspace utility
-- 
1.7.4

