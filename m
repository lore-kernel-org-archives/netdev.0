From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: Fix duplicate object rule
Date: Wed,  8 Feb 2017 14:40:04 -0800
Message-ID: <20170208224004.11786-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35916 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751459AbdBHWkQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 17:40:16 -0500
Received: by mail-qt0-f194.google.com with SMTP id h53so25173987qth.3
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 14:40:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While adding switch.o to the list of DSA object files, we essentially
duplicated the previous obj-y line and just added switch.o, remove the
duplicate.

Fixes: f515f192ab4f ("net: dsa: add switch notifier")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/Makefile | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index 72912982de3d..31d343796251 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -1,6 +1,5 @@
 # the core
 obj-$(CONFIG_NET_DSA) += dsa_core.o
-dsa_core-y += dsa.o slave.o dsa2.o
 dsa_core-y += dsa.o slave.o dsa2.o switch.o
 
 # tagging formats
-- 
2.9.3
