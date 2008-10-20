From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/07: ctnetlink: remove obsolete NAT dependency from Kconfig
Date: Mon, 20 Oct 2008 11:54:09 +0200 (MEST)
Message-ID: <20081020095409.25670.25267.sendpatchset@x2.localnet>
References: <20081020095408.25670.37455.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081020095408.25670.37455.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 2bb419e1548ba64e2eee5c7d8c900ad4b8dcf965
Author: Patrick McHardy <kaber@trash.net>
Date:   Sat Oct 18 15:20:56 2008 +0200

    netfilter: ctnetlink: remove obsolete NAT dependency from Kconfig
    
    Now that ctnetlink doesn't have any NAT module depenencies anymore,
    we can also remove them from Kconfig.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 78892cf..25dcef9 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -271,7 +271,6 @@ config NF_CONNTRACK_TFTP
 config NF_CT_NETLINK
 	tristate 'Connection tracking netlink interface'
 	select NETFILTER_NETLINK
-	depends on NF_NAT=n || NF_NAT
 	default m if NETFILTER_ADVANCED=n
 	help
 	  This option enables support for a netlink-based userspace interface
