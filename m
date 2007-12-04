From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 (resend) 1/11][CORE] Remove unneeded ifdefs from
 sysctl_net_core.c
Date: Tue, 04 Dec 2007 13:21:33 +0300
Message-ID: <47552A2D.4030003@openvz.org>
References: <4755256F.9000505@openvz.org> <475525DA.3050002@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56498 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752049AbXLDKVr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 05:21:47 -0500
In-Reply-To: <475525DA.3050002@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oops! Sorry, David, I've trimmed your e-mail when replied on 
the zeroth letter to send this patch and sent it to myself :)

Log:

This file is already compiled out when the SYSCTL=n, so
these ifdefs, that enclose the whole file, can be removed.

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
-- 1.5.3.4 
