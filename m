From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH v3 3/4] net/at91_ether: select MACB in Kconfig
Date: Mon, 22 Oct 2012 20:45:33 +0200
Message-ID: <1350931534-8416-4-git-send-email-manabian@gmail.com>
References: <1350931534-8416-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net,
	hskinnemoen@gmail.com, egtvedt@samfundet.no, plagnioj@jcrosoft.com,
	bgat@billgatliff.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:40166 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756059Ab2JVSrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 14:47:20 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so1824425lag.19
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 11:47:19 -0700 (PDT)
In-Reply-To: <1350931534-8416-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that HAVE_NET_MACB is gone let's just select MACB to
satisfy the dependecies in at91_ether.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/cadence/Kconfig  | 2 +-
 drivers/net/ethernet/cadence/Makefile | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
index 5d1ea30..f6d0956 100644
--- a/drivers/net/ethernet/cadence/Kconfig
+++ b/drivers/net/ethernet/cadence/Kconfig
@@ -23,7 +23,7 @@ config ARM_AT91_ETHER
 	tristate "AT91RM9200 Ethernet support"
 	depends on ARM && ARCH_AT91RM9200
 	select NET_CORE
-	select PHYLIB
+	select MACB
 	---help---
 	  If you wish to compile a kernel for the AT91RM9200 and enable
 	  ethernet support, then you should always answer Y to this.
diff --git a/drivers/net/ethernet/cadence/Makefile b/drivers/net/ethernet/cadence/Makefile
index 798b1e0..9068b83 100644
--- a/drivers/net/ethernet/cadence/Makefile
+++ b/drivers/net/ethernet/cadence/Makefile
@@ -2,5 +2,5 @@
 # Makefile for the Atmel network device drivers.
 #
 
-obj-$(CONFIG_ARM_AT91_ETHER) += at91_ether.o macb.o
+obj-$(CONFIG_ARM_AT91_ETHER) += at91_ether.o
 obj-$(CONFIG_MACB) += macb.o
-- 
1.7.12.4
