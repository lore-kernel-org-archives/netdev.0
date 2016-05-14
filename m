From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -next v2 1/4] net: w5100: remove unused is_w5200()
Date: Sat, 14 May 2016 14:55:47 +0900
Message-ID: <1463205350-7089-2-git-send-email-akinobu.mita@gmail.com>
References: <1463205350-7089-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Mike Sinkovsky <msink@permonline.ru>,
	"David S . Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36560 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735AbcENF4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 01:56:33 -0400
Received: by mail-pf0-f193.google.com with SMTP id g132so10899192pfb.3
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 22:56:33 -0700 (PDT)
In-Reply-To: <1463205350-7089-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The is_w5200() function is not used anymore by the commit which adds
the W5500 support.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Mike Sinkovsky <msink@permonline.ru>
Cc: David S. Miller <davem@davemloft.net>
---
* No changes from v1

 drivers/net/ethernet/wiznet/w5100.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 8ed0c77..56ceed9 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -173,11 +173,6 @@ struct w5100_priv {
 	struct work_struct restart_work;
 };
 
-static inline bool is_w5200(struct w5100_priv *priv)
-{
-	return priv->ops->chip_id == W5200;
-}
-
 /************************************************************************
  *
  *  Lowlevel I/O functions
-- 
2.7.4
