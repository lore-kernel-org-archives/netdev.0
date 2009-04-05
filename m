From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] net/802/fddi.c: add MODULE_LICENSE
Date: Sun, 5 Apr 2009 19:36:21 +0300
Message-ID: <20090405163621.GC3718@localhost.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.welho.com ([213.243.153.40]:36346 "EHLO smtp6.welho.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751616AbZDERGk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Apr 2009 13:06:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the missing MODULE_LICENSE("GPL").

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
--- a/net/802/fddi.c
+++ b/net/802/fddi.c
@@ -215,3 +215,5 @@ struct net_device *alloc_fddidev(int sizeof_priv)
 	return alloc_netdev(sizeof_priv, "fddi%d", fddi_setup);
 }
 EXPORT_SYMBOL(alloc_fddidev);
+
+MODULE_LICENSE("GPL");

