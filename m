From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH v5 7/7] ipv6 addrconf: change default MAX_RTR_SOLICITATIONS from 3 to -1 (unlimited)
Date: Tue, 27 Sep 2016 02:52:43 -0700
Message-ID: <1474969963-17402-8-git-send-email-zenczykowski@gmail.com>
References: <CANP3RGfHPZLHFnp4Rq8_dRNCro6Uh8O8767NgoGu7gvzu5h9BQ@mail.gmail.com>
 <1474969963-17402-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:32911 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932352AbcI0JxD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 05:53:03 -0400
Received: by mail-pa0-f65.google.com with SMTP id oz2so511383pac.0
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 02:53:02 -0700 (PDT)
In-Reply-To: <1474969963-17402-1-git-send-email-zenczykowski@gmail.com>
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
