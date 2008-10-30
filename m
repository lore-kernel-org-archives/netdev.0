From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] xfrm: C99 for xfrm_dev_notifier
Date: Thu, 30 Oct 2008 12:44:07 +0300
Message-ID: <20081030094407.GA5742@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:17684 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259AbYJ3Jks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 05:40:48 -0400
Received: by ey-out-2122.google.com with SMTP id 6so174823eyi.37
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 02:40:46 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/xfrm/xfrm_policy.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2379,9 +2379,7 @@ static int xfrm_dev_event(struct notifier_block *this, unsigned long event, void
 }
 
 static struct notifier_block xfrm_dev_notifier = {
-	xfrm_dev_event,
-	NULL,
-	0
+	.notifier_call	= xfrm_dev_event,
 };
 
 #ifdef CONFIG_XFRM_STATISTICS
