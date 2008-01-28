From: maximilian attems <max@stro.at>
Subject: [PATCH] [AX25]: Beautify x25_init() version printk.
Date: Mon, 28 Jan 2008 18:31:10 +0100
Message-ID: <1201541470-25312-2-git-send-email-max@stro.at>
References: <1201541470-25312-1-git-send-email-max@stro.at>
Cc: netdev@vger.kernel.org, maximilian attems <max@stro.at>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:53629 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760610AbYA1Rbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 12:31:48 -0500
In-Reply-To: <1201541470-25312-1-git-send-email-max@stro.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kill ref to old version and dup Linux.

Signed-off-by: maximilian attems <max@stro.at>
---
 net/x25/af_x25.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 92cfe8e..d0dbce0 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1652,7 +1652,7 @@ static int __init x25_init(void)
 
 	register_netdevice_notifier(&x25_dev_notifier);
 
-	printk(KERN_INFO "X.25 for Linux. Version 0.2 for Linux 2.1.15\n");
+	printk(KERN_INFO "X.25 for Linux Version 0.2\n");
 
 #ifdef CONFIG_SYSCTL
 	x25_register_sysctl();
-- 
1.5.4.rc4

