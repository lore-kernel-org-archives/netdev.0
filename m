From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH v2 6/7] ipv6 addrconf: change default RTR_SOLICITATION_MAX_INTERVAL from 4s to 1h
Date: Sun, 25 Sep 2016 02:59:55 -0700
Message-ID: <1474797596-13320-6-git-send-email-zenczykowski@gmail.com>
References: <20160925.053302.1895311145903319224.davem@davemloft.net>
 <1474797596-13320-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36629 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754547AbcIYKAQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 06:00:16 -0400
Received: by mail-pf0-f194.google.com with SMTP id n24so7546746pfb.3
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 03:00:16 -0700 (PDT)
In-Reply-To: <1474797596-13320-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej Żenczykowski <maze@google.com>

This changes:
  /proc/sys/net/ipv6/conf/all/router_solicitation_max_interval
  /proc/sys/net/ipv6/conf/default/router_solicitation_max_interval
from 4 seconds to 1 hour.

This is the https://tools.ietf.org/html/rfc7559 recommended default.

Signed-off-by: Maciej Żenczykowski <maze@google.com>
---
 include/net/addrconf.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 275e5af4c2f4..8f3677269f9a 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -3,7 +3,7 @@
 
 #define MAX_RTR_SOLICITATIONS		3
 #define RTR_SOLICITATION_INTERVAL	(4*HZ)
-#define RTR_SOLICITATION_MAX_INTERVAL	(4*HZ)
+#define RTR_SOLICITATION_MAX_INTERVAL	(3600*HZ)	/* 1 hour */
 
 #define MIN_VALID_LIFETIME		(2*3600)	/* 2 hours */
 
-- 
2.8.0.rc3.226.g39d4020
