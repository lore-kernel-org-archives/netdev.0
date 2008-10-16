From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH 1/1] netdev: DM9000: remove BLACKFIN hacking in DM9000 netdev driver
Date: Fri, 17 Oct 2008 01:40:44 +0800
Message-ID: <1224178844-12496-1-git-send-email-cooloney@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bryan Wu <cooloney@kernel.org>
To: ben@simtec.co.uk, davem@davemloft.net, vapier.adi@gmail.com,
	shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.184]:17118 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457AbYJPRkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 13:40:16 -0400
Received: by ti-out-0910.google.com with SMTP id b6so48966tic.23
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2008 10:40:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

remove integer casting in the read/write IO accessors,
because Blackfin now provides those functions

Tested-by: Javier Herrero <jherrero@hvsistemas.es>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 drivers/net/dm9000.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index f42c23f..5a9083e 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -47,15 +47,6 @@
 #define CARDNAME	"dm9000"
 #define DRV_VERSION	"1.31"
 
-#ifdef CONFIG_BLACKFIN
-#define readsb	insb
-#define readsw	insw
-#define readsl	insl
-#define writesb	outsb
-#define writesw	outsw
-#define writesl	outsl
-#endif
-
 /*
  * Transmit timeout, default 5 seconds.
  */
-- 
1.5.6

