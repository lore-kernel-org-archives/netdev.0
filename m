From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 2.6.20-rc5 2/4] atl1: add missing include dma-mapping.h
Date: Sat, 27 Jan 2007 18:11:45 -0600
Message-ID: <20070128001145.GB10269@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net,
	akpm@osdl.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf21aec.mail.bellsouth.net ([205.152.59.69]:35386 "EHLO
	imf21aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932155AbXA1ALq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jan 2007 19:11:46 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Jay Cliburn <jacliburn@bellsouth.com>

Include dma-mapphing.h to provide DMA_32BIT_MASK and DMA_64BIT_MASK.
Discovered by and modification suggested by Andrew Morton.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---

 drivers/net/atl1/atl1_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 68e6cd1..a9e02d1 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -66,6 +66,7 @@
 #include <linux/hardirq.h>
 #include <linux/interrupt.h>
 #include <linux/irqflags.h>
+#include <linux/dma-mapping.h>
 #include <linux/net.h>
 #include <linux/pm.h>
 #include <linux/in.h>
