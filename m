From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] make drivers/net/forcedeth.c:nv_update_pause() static
Date: Thu, 22 Jun 2006 12:03:29 +0200
Message-ID: <20060622100329.GB9111@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Manfred Spraul <manfred@colorfullife.com>,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:44303 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1161034AbWFVKDa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 06:03:30 -0400
To: Ayaz Abdulla <aabdulla@nvidia.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes the needlessly global nv_update_pause() static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 16 May 2006

--- linux-2.6.17-rc4-mm1-full/drivers/net/forcedeth.c.old	2006-05-16 13:03:01.000000000 +0200
+++ linux-2.6.17-rc4-mm1-full/drivers/net/forcedeth.c	2006-05-16 13:03:08.000000000 +0200
@@ -2221,7 +2221,7 @@
 	spin_unlock_irq(&np->lock);
 }
 
-void nv_update_pause(struct net_device *dev, u32 pause_flags)
+static void nv_update_pause(struct net_device *dev, u32 pause_flags)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);

