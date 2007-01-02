From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: [PATCH] net: af_netlink module_put cleanup
Date: Tue, 2 Jan 2007 13:47:37 +0100
Message-ID: <200701021347.37952.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xdsl-664.zgora.dialog.net.pl ([81.168.226.152]:3759 "EHLO
	tuxland.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753505AbXABMqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jan 2007 07:46:15 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

	This patch removes redundant argument check for module_put().

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

 net/netlink/af_netlink.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -upr linux-2.6.20-rc2-mm1-a/net/netlink/af_netlink.c linux-2.6.20-rc2-mm1-b/net/netlink/af_netlink.c
--- linux-2.6.20-rc2-mm1-a/net/netlink/af_netlink.c	2006-12-24 05:00:32.000000000 +0100
+++ linux-2.6.20-rc2-mm1-b/net/netlink/af_netlink.c	2007-01-02 02:23:02.000000000 +0100
@@ -472,8 +472,7 @@ static int netlink_release(struct socket
 				NETLINK_URELEASE, &n);
 	}	
 
-	if (nlk->module)
-		module_put(nlk->module);
+	module_put(nlk->module);
 
 	netlink_table_grab();
 	if (nlk->flags & NETLINK_KERNEL_SOCKET) {


-- 
Regards,

	Mariusz Kozlowski
