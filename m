From: akpm@osdl.org
Subject: [patch 12/13] make ibmveth link always up
Date: Sun, 21 Nov 2004 22:43:58 -0800
Message-ID: <200411220644.iAM6iA900690@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, santil@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Santiago Leon <santil@us.ibm.com>

The attached patch makes the ibmveth driver indicate that its link is
always up rather than always down, thus allowing the userspace side of
booting to configure the network interface correctly.

Signed-Off-By: Santiago Leon <santil@us.ibm.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/ibmveth.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/ibmveth.c~make-ibmveth-link-always-up drivers/net/ibmveth.c
--- 25/drivers/net/ibmveth.c~make-ibmveth-link-always-up	2004-11-21 22:42:53.895488880 -0800
+++ 25-akpm/drivers/net/ibmveth.c	2004-11-21 22:42:53.898488424 -0800
@@ -598,7 +598,7 @@ static void netdev_get_drvinfo (struct n
 }
 
 static u32 netdev_get_link(struct net_device *dev) {
-	return 0;
+	return 1;
 }
 
 static struct ethtool_ops netdev_ethtool_ops = {
_
