From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/4] clip: add module info
Date: Thu, 13 Apr 2006 15:24:32 -0700
Message-ID: <20060413152432.488e6487@localhost.localdomain>
References: <20060412105545.3b089dd8@localhost.localdomain>
	<20060413152224.2d46df99@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:14480 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932469AbWDMWZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 18:25:56 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060413152224.2d46df99@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add module information

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- clip.orig/net/atm/clip.c	2006-04-13 15:20:38.000000000 -0700
+++ clip/net/atm/clip.c	2006-04-13 15:23:41.000000000 -0700
@@ -1017,5 +1017,6 @@
 
 module_init(atm_clip_init);
 module_exit(atm_clip_exit);
-
+MODULE_AUTHOR("Werner Almesberger");
+MODULE_DESCRIPTION("Classical/IP over ATM interface");
 MODULE_LICENSE("GPL");
