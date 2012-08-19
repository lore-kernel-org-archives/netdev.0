From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH] net/core/dev.c: fix kernel-doc warning
Date: Sat, 18 Aug 2012 17:36:44 -0700
Message-ID: <5030351C.8080000@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy11-pub.bluehost.com ([173.254.64.10]:38684 "HELO
	oproxy11-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751961Ab2HSAgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Aug 2012 20:36:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@xenotime.net>

Fix kernel-doc warning:

Warning(net/core/dev.c:5745): No description found for parameter 'dev'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
Cc:	"David S. Miller" <davem@davemloft.net>
Cc:	netdev@vger.kernel.org
---
 net/core/dev.c |    1 +
 1 file changed, 1 insertion(+)

--- lnx-36-rc2.orig/net/core/dev.c
+++ lnx-36-rc2/net/core/dev.c
@@ -5732,6 +5732,7 @@ EXPORT_SYMBOL(netdev_refcnt_read);
 
 /**
  * netdev_wait_allrefs - wait until all references are gone.
+ * @dev: target net_device
  *
  * This is called when unregistering network devices.
  *
