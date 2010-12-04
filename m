From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 2/3] ifb: remove unused macro TX_TIMEOUT
Date: Sat,  4 Dec 2010 13:55:20 +0800
Message-ID: <1291442121-3302-2-git-send-email-xiaosuo@gmail.com>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Changli Gao <xiaosuo@gmail.com>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:43920 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128Ab0LDF4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 00:56:03 -0500
Received: by gxk19 with SMTP id 19so5511255gxk.11
        for <netdev@vger.kernel.org>; Fri, 03 Dec 2010 21:56:02 -0800 (PST)
In-Reply-To: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 drivers/net/ifb.c |    2 --
 1 file changed, 2 deletions(-)
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 4387525..d1e362a 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -36,8 +36,6 @@
 #include <net/pkt_sched.h>
 #include <net/net_namespace.h>
 
-#define TX_TIMEOUT  (2*HZ)
-
 #define TX_Q_LIMIT    32
 struct ifb_private {
 	struct tasklet_struct   ifb_tasklet;
