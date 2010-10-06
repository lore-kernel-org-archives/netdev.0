From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: [PATCH -next] sundance: Drop legacy _COMPAT_WITH_OLD_KERNEL
	includes
Date: Wed, 6 Oct 2010 13:59:56 +0000
Message-ID: <20101006135956.GA5556@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:46708 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758942Ab0JFN76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 09:59:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drop legacy includes since 2.4.x

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/sundance.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 8b5aeca..27d69aa 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -97,16 +97,9 @@ static char *media[MAX_UNITS];
 #include <linux/delay.h>
 #include <linux/spinlock.h>
 #include <linux/dma-mapping.h>
-#ifndef _COMPAT_WITH_OLD_KERNEL
 #include <linux/crc32.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
-#else
-#include "crc32.h"
-#include "ethtool.h"
-#include "mii.h"
-#include "compat.h"
-#endif
 
 /* These identify the driver base version and may not be removed. */
 static const char version[] __devinitconst =
-- 
1.7.0

