From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 01/27] sfc: Remove redundant header gmii.h
Date: Fri, 23 Oct 2009 19:28:45 +0100
Message-ID: <1256322525.2785.5.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8483 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646AbZJWS2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:28:43 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon_gmac.c |    1 -
 drivers/net/sfc/gmii.h        |   60 -----------------------------------------
 2 files changed, 0 insertions(+), 61 deletions(-)
 delete mode 100644 drivers/net/sfc/gmii.h

diff --git a/drivers/net/sfc/falcon_gmac.c b/drivers/net/sfc/falcon_gmac.c
index 8865eae..36f57b1 100644
--- a/drivers/net/sfc/falcon_gmac.c
+++ b/drivers/net/sfc/falcon_gmac.c
@@ -15,7 +15,6 @@
 #include "mac.h"
 #include "falcon_hwdefs.h"
 #include "falcon_io.h"
-#include "gmii.h"
 
 /**************************************************************************
  *
diff --git a/drivers/net/sfc/gmii.h b/drivers/net/sfc/gmii.h
deleted file mode 100644
index dfccaa7..0000000
--- a/drivers/net/sfc/gmii.h
+++ /dev/null
@@ -1,60 +0,0 @@
-/****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2008 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation, incorporated herein by reference.
- */
-
-#ifndef EFX_GMII_H
-#define EFX_GMII_H
-
-/*
- * GMII interface
- */
-
-#include <linux/mii.h>
-
-/* GMII registers, excluding registers already defined as MII
- * registers in mii.h
- */
-#define GMII_IER		0x12	/* Interrupt enable register */
-#define GMII_ISR		0x13	/* Interrupt status register */
-
-/* Interrupt enable register */
-#define IER_ANEG_ERR		0x8000	/* Bit 15 - autonegotiation error */
-#define IER_SPEED_CHG		0x4000	/* Bit 14 - speed changed */
-#define IER_DUPLEX_CHG		0x2000	/* Bit 13 - duplex changed */
-#define IER_PAGE_RCVD		0x1000	/* Bit 12 - page received */
-#define IER_ANEG_DONE		0x0800	/* Bit 11 - autonegotiation complete */
-#define IER_LINK_CHG		0x0400	/* Bit 10 - link status changed */
-#define IER_SYM_ERR		0x0200	/* Bit 9 - symbol error */
-#define IER_FALSE_CARRIER	0x0100	/* Bit 8 - false carrier */
-#define IER_FIFO_ERR		0x0080	/* Bit 7 - FIFO over/underflow */
-#define IER_MDIX_CHG		0x0040	/* Bit 6 - MDI crossover changed */
-#define IER_DOWNSHIFT		0x0020	/* Bit 5 - downshift */
-#define IER_ENERGY		0x0010	/* Bit 4 - energy detect */
-#define IER_DTE_POWER		0x0004	/* Bit 2 - DTE power detect */
-#define IER_POLARITY_CHG	0x0002	/* Bit 1 - polarity changed */
-#define IER_JABBER		0x0001	/* Bit 0 - jabber */
-
-/* Interrupt status register */
-#define ISR_ANEG_ERR		0x8000	/* Bit 15 - autonegotiation error */
-#define ISR_SPEED_CHG		0x4000	/* Bit 14 - speed changed */
-#define ISR_DUPLEX_CHG		0x2000	/* Bit 13 - duplex changed */
-#define ISR_PAGE_RCVD		0x1000	/* Bit 12 - page received */
-#define ISR_ANEG_DONE		0x0800	/* Bit 11 - autonegotiation complete */
-#define ISR_LINK_CHG		0x0400	/* Bit 10 - link status changed */
-#define ISR_SYM_ERR		0x0200	/* Bit 9 - symbol error */
-#define ISR_FALSE_CARRIER	0x0100	/* Bit 8 - false carrier */
-#define ISR_FIFO_ERR		0x0080	/* Bit 7 - FIFO over/underflow */
-#define ISR_MDIX_CHG		0x0040	/* Bit 6 - MDI crossover changed */
-#define ISR_DOWNSHIFT		0x0020	/* Bit 5 - downshift */
-#define ISR_ENERGY		0x0010	/* Bit 4 - energy detect */
-#define ISR_DTE_POWER		0x0004	/* Bit 2 - DTE power detect */
-#define ISR_POLARITY_CHG	0x0002	/* Bit 1 - polarity changed */
-#define ISR_JABBER		0x0001	/* Bit 0 - jabber */
-
-#endif /* EFX_GMII_H */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

