From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 4/23] [PATCH] [XFRM]: Fix message about transformation user interface.
Date: Sat, 29 Jul 2006 18:30:07 +0900
Message-ID: <11541654071107-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:14979 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1751229AbWG2JaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:10 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Transformation user interface is not only for IPsec.
Based on MIPL2 kernel patch.
---
 net/xfrm/Kconfig     |    6 +++---
 net/xfrm/xfrm_user.c |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index 95f4f09..50f2fb3 100644
--- a/net/xfrm/Kconfig
+++ b/net/xfrm/Kconfig
@@ -6,11 +6,11 @@ config XFRM
        depends on NET
 
 config XFRM_USER
-	tristate "IPsec user configuration interface"
+	tristate "Transformation user configuration interface"
 	depends on INET && XFRM
 	---help---
-	  Support for IPsec user configuration interface used
-	  by native Linux tools.
+	  Support for Transformation(XFRM) user configuration interface
+	  like IPsec used by native Linux tools.
 
 	  If unsure, say Y.
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 9516da3..f92d163 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1949,7 +1949,7 @@ static int __init xfrm_user_init(void)
 {
 	struct sock *nlsk;
 
-	printk(KERN_INFO "Initializing IPsec netlink socket\n");
+	printk(KERN_INFO "Initializing XFRM netlink socket\n");
 
 	nlsk = netlink_kernel_create(NETLINK_XFRM, XFRMNLGRP_MAX,
 	                             xfrm_netlink_rcv, THIS_MODULE);
-- 
1.4.1

