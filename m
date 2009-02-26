From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] sungem: another error printed one too early
Date: Thu, 26 Feb 2009 13:55:43 +0100
Message-ID: <49A6914F.6070301@gmail.com>
References: <499971DC.4070406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Daniel Walker <dwalker@fifo99.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:22064 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021AbZBZMzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 07:55:48 -0500
Received: by ey-out-2122.google.com with SMTP id 25so132621eya.37
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 04:55:45 -0800 (PST)
In-Reply-To: <499971DC.4070406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roel Kluin wrote:
> Another error was printed one too early.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---

I am not sure why my script didn't report this earlier.
-----------------------------------------------------
Another error was printed one too early.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 8d64b1d..0fcb750 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -1229,7 +1229,7 @@ static void gem_reset(struct gem *gp)
 			break;
 	} while (val & (GREG_SWRST_TXRST | GREG_SWRST_RXRST));
 
-	if (limit <= 0)
+	if (limit < 0)
 		printk(KERN_ERR "%s: SW reset is ghetto.\n", gp->dev->name);
 
 	if (gp->phy_type == phy_serialink || gp->phy_type == phy_serdes)
