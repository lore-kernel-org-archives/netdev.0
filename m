From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/3] gre: add module alias for gre0 tunnel device
Date: Mon, 29 Nov 2010 11:47:48 -0800
Message-ID: <20101129194805.762508688@vyatta.com>
References: <20101129194746.724222156@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42250 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751074Ab0K2Tsc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Nov 2010 14:48:32 -0500
Content-Disposition: inline; filename=gre-alias.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If gre is built as a module the 'ip tunnel add' command would fail because
the ip_gre module was not being autoloaded.  Adding an alias for
the gre0 device name cause dev_load() to autoload it when needed.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/ip_gre.c	2010-11-29 11:35:36.388589982 -0800
+++ b/net/ipv4/ip_gre.c	2010-11-29 11:35:46.675624021 -0800
@@ -1764,3 +1764,4 @@ module_exit(ipgre_fini);
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_RTNL_LINK("gre");
 MODULE_ALIAS_RTNL_LINK("gretap");
+MODULE_ALIAS("gre0");


