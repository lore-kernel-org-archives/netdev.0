From: Manuel Lauss <manuel.lauss@googlemail.com>
Subject: [PATCH] net: au1000_eth: add missing capability.h
Date: Sat, 17 Oct 2009 14:00:07 +0200
Message-ID: <1255780807-991-1-git-send-email-manuel.lauss@gmail.com>
Cc: Manuel Lauss <manuel.lauss@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:33794 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbZJQL7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2009 07:59:34 -0400
Received: by fxm18 with SMTP id 18so3348932fxm.37
        for <netdev@vger.kernel.org>; Sat, 17 Oct 2009 04:59:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fixes the following build failure:
  CC      drivers/net/au1000_eth.o
/drivers/net/au1000_eth.c: In function 'au1000_set_settings':
/drivers/net/au1000_eth.c:623: error: implicit declaration of function 'capable'
/drivers/net/au1000_eth.c:623: error: 'CAP_NET_ADMIN' undeclared (first use in this function)
/drivers/net/au1000_eth.c:623: error: (Each undeclared identifier is reported only once
/drivers/net/au1000_eth.c:623: error: for each function it appears in.

Signed-off-by: Manuel Lauss <manuel.lauss@gmail.com>
---
 drivers/net/au1000_eth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 04f63c7..ce6f1ac 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -34,6 +34,7 @@
  *
  *
  */
+#include <linux/capability.h>
 #include <linux/dma-mapping.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
-- 
1.6.5.rc2

