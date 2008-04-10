From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: [PATCH] sky2: missing chip name for Yukon Supreme
Date: Thu, 10 Apr 2008 15:06:14 -0500
Message-ID: <20080410150614.7da71ff8@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:45814 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752046AbYDJUGa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 16:06:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any usage of sky2 on new Yukon Supreme would cause a NULL dereference.
The chip is very new, so the support is still untested; vendor has
not sent any eval hardware.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
Please apply for 2.6.25

--- a/drivers/net/sky2.c	2008-04-10 14:01:05.000000000 -0500
+++ b/drivers/net/sky2.c	2008-04-10 14:04:23.000000000 -0500
@@ -154,6 +154,7 @@ static const char *yukon2_name[] = {
 	"EC",		/* 0xb6 */
 	"FE",		/* 0xb7 */
 	"FE+",		/* 0xb8 */
+	"Supreme",	/* 0xb9 */
 };
 
 static void sky2_set_multicast(struct net_device *dev);
