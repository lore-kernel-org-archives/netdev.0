From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH 7/7] ipv6 addrconf: change default MAX_RTR_SOLICITATIONS from 3 to -1 (unlimited)
Date: Sat, 24 Sep 2016 09:05:09 -0700
Message-ID: <1474733109-18355-7-git-send-email-zenczykowski@gmail.com>
References: <CAHo-Oozocj2rzY8hTTr1f3roMy9iz50j6X=dBG5qmz4B_LFAFQ@mail.gmail.com>
 <1474733109-18355-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35928 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758107AbcIXQGF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 12:06:05 -0400
Received: by mail-pf0-f195.google.com with SMTP id n24so6707130pfb.3
        for <netdev@vger.kernel.org>; Sat, 24 Sep 2016 09:06:05 -0700 (PDT)
In-Reply-To: <1474733109-18355-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej Żenczykowski <maze@google.com>

This changes:
  /proc/sys/net/ipv6/conf/all/router_solicitations
  /proc/sys/net/ipv6/conf/default/router_solicitations
from 3 to unlimited.

This is the https://tools.ietf.org/html/rfc7559 recommended default.

Signed-off-by: Maciej Żenczykowski <maze@google.com>
---
 include/net/addrconf.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 8f3677269f9a..f2d072787947 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -1,7 +1,7 @@
 #ifndef _ADDRCONF_H
 #define _ADDRCONF_H
 
-#define MAX_RTR_SOLICITATIONS		3
+#define MAX_RTR_SOLICITATIONS		-1		/* unlimited */
 #define RTR_SOLICITATION_INTERVAL	(4*HZ)
 #define RTR_SOLICITATION_MAX_INTERVAL	(3600*HZ)	/* 1 hour */
 
-- 
2.8.0.rc3.226.g39d4020
