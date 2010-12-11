From: Manuel Lauss <manuel.lauss@googlemail.com>
Subject: [PATCH] net: au1000_eth: remove unused global variable.
Date: Sat, 11 Dec 2010 20:53:42 +0100
Message-ID: <1292097222-11319-1-git-send-email-manuel.lauss@googlemail.com>
Cc: Florian Fainelli <florian@openwrt.org>,
	Manuel Lauss <manuel.lauss@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56451 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345Ab0LKTxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 14:53:47 -0500
Received: by wyb28 with SMTP id 28so4607210wyb.19
        for <netdev@vger.kernel.org>; Sat, 11 Dec 2010 11:53:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver global au_macs[] is unused in the entire kernel tree,
so remove it.

Signed-off-by: Manuel Lauss <manuel.lauss@googlemail.com>
---
 drivers/net/au1000_eth.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 53eff9b..b9debcf 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -106,8 +106,6 @@ MODULE_VERSION(DRV_VERSION);
  * complete immediately.
  */
 
-struct au1000_private *au_macs[NUM_ETH_INTERFACES];
-
 /*
  * board-specific configurations
  *
-- 
1.7.3.3

