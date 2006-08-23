From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 17/44] [XFRM]: Fix message about transformation user interface.
Date: Thu, 24 Aug 2006 00:02:18 +0900
Message-ID: <11563453661207-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:2953 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964931AbWHWPCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:51 -0400
To: davem@davemloft.net
In-Reply-To: <11563453661892-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Transformation user interface is not only for IPsec.
Based on MIPL2 kernel patch.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/xfrm/Kconfig     |    6 +++---
 net/xfrm/xfrm_user.c |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index 0c1c043..43228f7 100644
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
index 6511085..642ec66 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2052,7 +2052,7 @@ static int __init xfrm_user_init(void)
 {
 	struct sock *nlsk;
 
-	printk(KERN_INFO "Initializing IPsec netlink socket\n");
+	printk(KERN_INFO "Initializing XFRM netlink socket\n");
 
 	nlsk = netlink_kernel_create(NETLINK_XFRM, XFRMNLGRP_MAX,
 	                             xfrm_netlink_rcv, THIS_MODULE);
-- 
1.4.0

