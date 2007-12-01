From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 1/6][CORE] Remove unneeded ifdefs from sysctl_net_core.c
Date: Sat, 01 Dec 2007 15:57:13 +0300
Message-ID: <47515A29.3070806@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:60858 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753069AbXLAM5Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 07:57:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They include the whole file, but it is already compiled
out when SYSCTL=n, since it is obj-$(CONFIG_SYSCTL) target
in the Makefile.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 113cc72..277c8fa 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -13,8 +13,6 @@
 #include <net/sock.h>
 #include <net/xfrm.h>
 
-#ifdef CONFIG_SYSCTL
-
 ctl_table core_table[] = {
 #ifdef CONFIG_NET
 	{
@@ -151,5 +149,3 @@ ctl_table core_table[] = {
 	},
 	{ .ctl_name = 0 }
 };
-
-#endif
-- 
1.5.3.4

