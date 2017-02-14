From: Manuel Lauss <manuel.lauss@gmail.com>
Subject: [PATCH 2/2] net: irda: au1k_ir: drop useless include
Date: Tue, 14 Feb 2017 13:08:04 +0100
Message-ID: <20170214120804.248871-2-manuel.lauss@gmail.com>
References: <20170214120804.248871-1-manuel.lauss@gmail.com>
Cc: Manuel Lauss <manuel.lauss@gmail.com>
To: netdev@vger.kernel.org, Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33925 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751930AbdBNMIJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 07:08:09 -0500
Received: by mail-wr0-f193.google.com with SMTP id c4so1848047wrd.1
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 04:08:08 -0800 (PST)
In-Reply-To: <20170214120804.248871-1-manuel.lauss@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

remove useless ioport.h include.

Signed-off-by: Manuel Lauss <manuel.lauss@gmail.com>
---
 drivers/net/irda/au1k_ir.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index bc2a63f5ca8c..be4ea6aa57a9 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -25,7 +25,6 @@
 #include <linux/platform_device.h>
 #include <linux/slab.h>
 #include <linux/types.h>
-#include <linux/ioport.h>
 
 #include <net/irda/irda.h>
 #include <net/irda/irmod.h>
-- 
2.11.1
