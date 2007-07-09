From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: [PATCH] spidernet: don't use debug flag
Date: Mon, 09 Jul 2007 17:45:21 +0900 (JST)
Message-ID: <20070709.174521.-1300522077.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx9.toshiba.co.jp ([202.33.96.51]:59834 "EHLO
	imx9.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088AbXGIJVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 05:21:02 -0400
Received: from inet-tsb5.toshiba.co.jp (inet-tsb5 [202.33.96.24])
	by imx9.toshiba.co.jp  with ESMTP id l699L0hT021861
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 18:21:00 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

GDTDCEIDIS flag is defined that it is for debug and should not be used.
We met some troubles on Celleb platform by setting this flag.
 -network does not recover after ifconfig down, then up operations.

Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
---

Index: linux-powerpc-git/drivers/net/spider_net.h
diff -u linux-powerpc-git/drivers/net/spider_net.h:1.1.1.4 linux-powerpc-git/drivers/net/spider_net.h:1.8
--- linux-powerpc-git/drivers/net/spider_net.h:1.1.1.4	Tue Jul  3 15:43:24 2007
+++ linux-powerpc-git/drivers/net/spider_net.h	Fri Jul  6 14:07:00 2007
@@ -222,7 +222,6 @@
 #define SPIDER_NET_GDTBSTA             0x00000300
 #define SPIDER_NET_GDTDCEIDIS          0x00000002
 #define SPIDER_NET_DMA_TX_VALUE        SPIDER_NET_TX_DMA_EN | \
-                                       SPIDER_NET_GDTDCEIDIS | \
                                        SPIDER_NET_GDTBSTA
 
 #define SPIDER_NET_DMA_TX_FEND_VALUE	0x00030003
