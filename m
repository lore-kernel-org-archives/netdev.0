From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next] ipvlan: Fix dependency issue
Date: Mon, 19 Sep 2016 13:56:29 -0700
Message-ID: <1474318589-6452-1-git-send-email-mahesh@bandewar.net>
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36496 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751955AbcISU4g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 16:56:36 -0400
Received: by mail-pa0-f65.google.com with SMTP id my20so4430569pab.3
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 13:56:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

kbuild-build-bot reported that if NETFILTER is not selected, the
build fails pointing to netfilter symbols.

Fixes: 4fbae7d83c98 ("ipvlan: Introduce l3s mode")

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 8768a625350d..95c32f2d7601 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -149,6 +149,7 @@ config IPVLAN
     tristate "IP-VLAN support"
     depends on INET
     depends on IPV6
+    depends on NETFILTER
     depends on NET_L3_MASTER_DEV
     ---help---
       This allows one to create virtual devices off of a main interface
-- 
2.8.0.rc3.226.g39d4020
