From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] phy/bitbang: missing MODULE_LICENSE
Date: Thu, 18 Oct 2007 12:20:21 -0700
Message-ID: <20071018122021.2acd128d.randy.dunlap@oracle.com>
References: <20070920220043.GA28769@loki.buserror.net>
	<20070920220123.GG28784@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:56522 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759419AbXJRTVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 15:21:46 -0400
In-Reply-To: <20070920220123.GG28784@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Missing MODULE_LICENSE(), loading this module taints the kernel.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/phy/mdio-bitbang.c |    2 ++
 1 file changed, 2 insertions(+)

--- linux-2.6.23-git7.orig/drivers/net/phy/mdio-bitbang.c
+++ linux-2.6.23-git7/drivers/net/phy/mdio-bitbang.c
@@ -185,3 +185,5 @@ void free_mdio_bitbang(struct mii_bus *b
 	module_put(ctrl->ops->owner);
 	kfree(bus);
 }
+
+MODULE_LICENSE("GPL");
