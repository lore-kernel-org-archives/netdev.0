From: Changhyeok Bae <changhyeok.bae@gmail.com>
Subject: [iproute2][PATCH] ip: Remove unneed header
Date: Mon, 12 Jun 2017 04:33:35 +0000
Message-ID: <1497242015-11611-1-git-send-email-changhyeok.bae@gmail.com>
Cc: stephen@networkplumber.org,
        Changhyeok Bae <changhyeok.bae@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34652 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752000AbdFLEdn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 00:33:43 -0400
Received: by mail-pg0-f67.google.com with SMTP id v14so13201412pgn.1
        for <netdev@vger.kernel.org>; Sun, 11 Jun 2017 21:33:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix redefinition of struct ethhdr with a suitably patched musl libc
that suppresses the kernel if_ether.h.

Signed-off-by: Changhyeok Bae <changhyeok.bae@gmail.com>
---
 ip/iplink_bridge.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index cccdec1..f065b22 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -13,7 +13,6 @@
 #include <stdlib.h>
 #include <string.h>
 #include <netinet/in.h>
-#include <netinet/ether.h>
 #include <linux/if_link.h>
 #include <linux/if_bridge.h>
 #include <net/if.h>
-- 
2.7.4
