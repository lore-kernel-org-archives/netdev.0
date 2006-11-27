From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] NET_SCH_ATM doesn't need ipcommon.o
Date: Mon, 27 Nov 2006 01:59:34 +0100
Message-ID: <20061127005934.GN15364@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:59913 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1755703AbWK0A7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Nov 2006 19:59:30 -0500
To: chas@cmf.nrl.navy.mil
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NET_SCH_ATM doesn't need ipcommon.o

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.19-rc6-mm1/net/atm/Makefile.old	2006-11-26 08:50:05.000000000 +0100
+++ linux-2.6.19-rc6-mm1/net/atm/Makefile	2006-11-26 08:56:29.000000000 +0100
@@ -10,7 +10,6 @@
 atm-$(subst m,y,$(CONFIG_ATM_CLIP)) += ipcommon.o
 obj-$(CONFIG_ATM_BR2684) += br2684.o
 atm-$(subst m,y,$(CONFIG_ATM_BR2684)) += ipcommon.o
-atm-$(subst m,y,$(CONFIG_NET_SCH_ATM)) += ipcommon.o
 atm-$(CONFIG_PROC_FS) += proc.o
 
 obj-$(CONFIG_ATM_LANE) += lec.o
