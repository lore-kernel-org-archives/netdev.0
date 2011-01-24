From: David Miller <davem@davemloft.net>
Subject: [PATCH] typhoon: Kill references to UTS_RELEASE
Date: Mon, 24 Jan 2011 15:12:14 -0800 (PST)
Message-ID: <20110124.151214.28803162.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave@thedillows.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43410
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751300Ab1AXXLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 18:11:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This makes the driver get rebuilt every single time you
type 'make' which is beyond rediculious.

I hereby declare this driver to have version "1.0"

Signed-off-by: David S. Miller <davem@davemloft.net>
---

This has been driving me nuts for a long time.

 drivers/net/typhoon.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index a3c46f6..7fa5ec2 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -123,12 +123,11 @@ static const int multicast_filter_limit = 32;
 #include <linux/in6.h>
 #include <linux/dma-mapping.h>
 #include <linux/firmware.h>
-#include <generated/utsrelease.h>
 
 #include "typhoon.h"
 
 MODULE_AUTHOR("David Dillow <dave@thedillows.org>");
-MODULE_VERSION(UTS_RELEASE);
+MODULE_VERSION("1.0");
 MODULE_LICENSE("GPL");
 MODULE_FIRMWARE(FIRMWARE_NAME);
 MODULE_DESCRIPTION("3Com Typhoon Family (3C990, 3CR990, and variants)");
-- 
1.7.3.4

