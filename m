From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH] pxa168_eth: remove duplicated #include
Date: Tue, 31 Aug 2010 07:06:20 +0800
Message-ID: <1283209580-688-1-git-send-email-weiyi.huang@gmail.com>
Cc: netdev@vger.kernel.org, Huang Weiyi <weiyi.huang@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:59806 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028Ab0H3XG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 19:06:29 -0400
Received: by ywh1 with SMTP id 1so1864303ywh.19
        for <netdev@vger.kernel.org>; Mon, 30 Aug 2010 16:06:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicated #include('s) in
  drivers/net/pxa168_eth.c

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
---
 drivers/net/pxa168_eth.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
index 410ea0a..bb08168 100644
--- a/drivers/net/pxa168_eth.c
+++ b/drivers/net/pxa168_eth.c
@@ -42,8 +42,6 @@
 #include <linux/types.h>
 #include <asm/pgtable.h>
 #include <asm/system.h>
-#include <linux/delay.h>
-#include <linux/dma-mapping.h>
 #include <asm/cacheflush.h>
 #include <linux/pxa168_eth.h>
 
-- 
1.6.1.3

