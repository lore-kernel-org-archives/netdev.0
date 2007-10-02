From: akpm@linux-foundation.org
Subject: [patch 09/13] forcedeth: "no link" is informational
Date: Tue, 02 Oct 2007 14:11:41 -0700
Message-ID: <200710022111.l92LBf6c022501@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	eswierk@arastra.com, aabdulla@nvidia.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:45450 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754890AbXJBVMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:12:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ed Swierk" <eswierk@arastra.com>

Log "no link during initialization" at KERN_INFO as it's not an error, and
occurs every time the interface comes up (when the forcedeth-phy-power-down
patch is applied).

Signed-off-by: Ed Swierk <eswierk@arastra.com>
Cc: Ayaz Abdulla <aabdulla@nvidia.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/forcedeth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/forcedeth.c~forcedeth-no-link-is-informational drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~forcedeth-no-link-is-informational
+++ a/drivers/net/forcedeth.c
@@ -4921,7 +4921,7 @@ static int nv_open(struct net_device *de
 	if (ret) {
 		netif_carrier_on(dev);
 	} else {
-		printk("%s: no link during initialization.\n", dev->name);
+		printk(KERN_INFO "%s: no link during initialization.\n", dev->name);
 		netif_carrier_off(dev);
 	}
 	if (oom)
_
