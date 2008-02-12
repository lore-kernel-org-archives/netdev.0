From: maximilian attems <max@stro.at>
Subject: [PATCH] [IRDA] irda_init() nuke useless debug printk
Date: Tue, 12 Feb 2008 11:30:47 +0100
Message-ID: <1202812247-6878-1-git-send-email-max@stro.at>
Cc: netdev@vger.kernel.org, maximilian attems <max@stro.at>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:46364 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758846AbYBLKax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 05:30:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

irda_init()
dmesg line is not really informative, thus remove it.
There are better ways to know that a module is loaded.

Seen on a debian config with IRDA_DEBUG enabled.

Signed-off-by: maximilian attems <max@stro.at>
---
 net/irda/irmod.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/irda/irmod.c b/net/irda/irmod.c
index 01554b9..73db875 100644
--- a/net/irda/irmod.c
+++ b/net/irda/irmod.c
@@ -90,8 +90,6 @@ static int __init irda_init(void)
 {
 	int ret = 0;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__);
-
 	/* Lower layer of the stack */
 	irlmp_init();
 	irlap_init();
-- 
1.5.4

