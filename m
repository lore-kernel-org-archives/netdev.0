From: maximilian attems <max@stro.at>
Subject: [patch] starfire list alpha as 64 bit arch
Date: Sun, 24 Jun 2007 23:36:45 +0200
Message-ID: <20070624213645.GL4869@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ionut@cs.columbia.edu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:2620 "EHLO baikonur.stro.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751400AbXFXVgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jun 2007 17:36:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

instead of:
"This driver has not been ported to this 64-bit architecture yet."
the driver is said to work on alpha, see
http://bugs.debian.org/305330

Signed-off-by: maximilian attems <max@stro.at>


diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 9d6e454..786d4b9 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -152,7 +152,7 @@ static int full_duplex[MAX_UNITS] = {0, };
  * This SUCKS.
  * We need a much better method to determine if dma_addr_t is 64-bit.
  */
-#if (defined(__i386__) && defined(CONFIG_HIGHMEM64G)) || defined(__x86_64__) || defined (__ia64__) || defined(__mips64__) || (defined(__mips__) && defined(CONFIG_HIGHMEM) && defined(CONFIG_64BIT_PHYS_ADDR))
+#if (defined(__i386__) && defined(CONFIG_HIGHMEM64G)) || defined(__x86_64__) || defined (__ia64__) || defined(__alpha__) || defined(__mips64__) || (defined(__mips__) && defined(CONFIG_HIGHMEM) && defined(CONFIG_64BIT_PHYS_ADDR))
 /* 64-bit dma_addr_t */
 #define ADDR_64BITS	/* This chip uses 64 bit addresses. */
 #define netdrv_addr_t u64
