From: Patrick McHardy <kaber@trash.net>
Subject: [NETFILTER]: netbios conntrack: fix compile
Date: Sat, 05 Aug 2006 09:08:27 +0200
Message-ID: <44D443EB.1050006@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040400070305090908050302"
Cc: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34707 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1422674AbWHEHI1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 03:08:27 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040400070305090908050302
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Fix compilation of the netbios_ns helper in the net-2.6.19 tree.


--------------040400070305090908050302
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETFILTER]: netbios conntrack: fix compile

Fix compile breakage caused by move of IFA_F_SECONDARY to new header file.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 94f26313abdf7169af0a4afa0c3046927892f22c
tree 1a86a591f06f3da549a23308ca73a8e44f829259
parent 10365c03ef65f5bccc992d6b78f7ef037cb4f0e9
author Patrick McHardy <kaber@trash.net> Sat, 05 Aug 2006 09:07:30 +0200
committer Patrick McHardy <kaber@trash.net> Sat, 05 Aug 2006 09:07:30 +0200

 net/ipv4/netfilter/ip_conntrack_netbios_ns.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/netfilter/ip_conntrack_netbios_ns.c b/net/ipv4/netfilter/ip_conntrack_netbios_ns.c
index a566a81..3d0b438 100644
--- a/net/ipv4/netfilter/ip_conntrack_netbios_ns.c
+++ b/net/ipv4/netfilter/ip_conntrack_netbios_ns.c
@@ -21,6 +21,7 @@ #include <linux/init.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/inetdevice.h>
+#include <linux/if_addr.h>
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <net/route.h>

--------------040400070305090908050302--
