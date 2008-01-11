From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: [PATCH 3/5] spidernet: change interrupt masks
Date: Fri, 11 Jan 2008 15:43:43 +0900 (JST)
Message-ID: <20080111.154343.-1625861724.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx9.toshiba.co.jp ([202.33.96.51]:55503 "EHLO
	imx9.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755133AbYAKHUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 02:20:39 -0500
Received: from inet-tsb5.toshiba.co.jp (inet-tsb5 [202.33.96.24])
	by imx9.toshiba.co.jp  with ESMTP id m0B7KbV7003301
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 16:20:38 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes spidernet interrupt masks.

 - unmask GDAINVAINT. There is an operation to do by spidernet
   interrupt handler.
 - mask some interrupts. There are no operations in the interrupt handler.

Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
---

Index: linux-powerpc-git/drivers/net/spider_net.h
===================================================================
--- linux-powerpc-git.orig/drivers/net/spider_net.h
+++ linux-powerpc-git/drivers/net/spider_net.h
@@ -159,9 +159,8 @@ extern char spider_net_driver_name[];
 
 /** interrupt mask registers */
 #define SPIDER_NET_INT0_MASK_VALUE	0x3f7fe2c7
-#define SPIDER_NET_INT1_MASK_VALUE	0xffff7ff7
-/* no MAC aborts -> auto retransmission */
-#define SPIDER_NET_INT2_MASK_VALUE	0xffef7ff1
+#define SPIDER_NET_INT1_MASK_VALUE	0x0000fff2
+#define SPIDER_NET_INT2_MASK_VALUE	0x000003f1
 
 /* we rely on flagged descriptor interrupts */
 #define SPIDER_NET_FRAMENUM_VALUE	0x00000000
