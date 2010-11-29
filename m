From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/3] ipip: add module alias for tunl0 tunnel device
Date: Mon, 29 Nov 2010 11:47:49 -0800
Message-ID: <20101129194805.851988995@vyatta.com>
References: <20101129194746.724222156@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42249 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751493Ab0K2Tsc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Nov 2010 14:48:32 -0500
Content-Disposition: inline; filename=ipip-alias.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If ipip is built as a module the 'ip tunnel add' command would fail because
the ipip module was not being autoloaded.  Adding an alias for
the tunl0 device name cause dev_load() to autoload it when needed.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/ipip.c	2010-11-29 11:40:25.026277890 -0800
+++ b/net/ipv4/ipip.c	2010-11-29 11:41:05.790681069 -0800
@@ -913,3 +913,4 @@ static void __exit ipip_fini(void)
 module_init(ipip_init);
 module_exit(ipip_fini);
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("tunl0");


