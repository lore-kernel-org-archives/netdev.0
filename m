From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: vrf: Remove RT_FL_TOS
Date: Thu, 15 Sep 2016 10:13:47 -0700
Message-ID: <1473959627-5268-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36244 "EHLO
        mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750878AbcIORN6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 13:13:58 -0400
Received: by mail-pa0-f49.google.com with SMTP id id6so17706564pad.3
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 10:13:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No longer used after d66f6c0a8f3c0 ("net: ipv4: Remove l3mdev_get_saddr")

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 55674b0e65b7..85c271c70d42 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -37,9 +37,6 @@
 #include <net/l3mdev.h>
 #include <net/fib_rules.h>
 
-#define RT_FL_TOS(oldflp4) \
-	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
-
 #define DRV_NAME	"vrf"
 #define DRV_VERSION	"1.0"
 
-- 
2.1.4
