From: Karim Eshapa <karim.eshapa@gmail.com>
Subject: [PATCH 2/2] drivers:net:ethernet:3com:3c512: array char instead of char pointer
Date: Sat, 22 Apr 2017 02:17:39 +0200
Message-ID: <1492820259-5770-1-git-send-email-karim.eshapa@gmail.com>
Cc: jarod@redhat.com, felipe.balbi@linux.intel.com, a@unstable.cc,
        fw@strlen.de, tglx@linutronix.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Karim Eshapa <karim.eshapa@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36796 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1042915AbdDVARy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 20:17:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

char pointer creates two variables static string and pointer to it
according to Jeff Garzik janitors TODO

Signed-off-by: Karim Eshapa <karim.eshapa@gmail.com>
---
 drivers/net/ethernet/3com/3c515.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/3c515.c b/drivers/net/ethernet/3com/3c515.c
index e7b1fa5..29b8ddd 100644
--- a/drivers/net/ethernet/3com/3c515.c
+++ b/drivers/net/ethernet/3com/3c515.c
@@ -26,7 +26,7 @@
 #define DRV_VERSION		"0.99t-ac"
 #define DRV_RELDATE		"28-Oct-2002"
 
-static char *version =
+static char version[] =
 DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE " becker@scyld.com and others\n";
 
 #define CORKSCREW 1
-- 
2.7.4
