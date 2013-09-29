From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: add missing sk_max_pacing_rate doc
Date: Sun, 29 Sep 2013 01:12:40 -0700
Message-ID: <1380442360.3596.18.camel@edumazet-glaptop.roam.corp.google.com>
References: <1379949014.3165.24.camel@edumazet-glaptop>
	 <1380036052.3165.71.camel@edumazet-glaptop>
	 <20130928.153610.2280100769720851440.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:51654 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645Ab3I2IMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Sep 2013 04:12:42 -0400
Received: by mail-pd0-f170.google.com with SMTP id x10so4358963pdj.29
        for <netdev@vger.kernel.org>; Sun, 29 Sep 2013 01:12:41 -0700 (PDT)
In-Reply-To: <20130928.153610.2280100769720851440.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Warning(include/net/sock.h:411): No description found for parameter
'sk_max_pacing_rate'

Lets please "make htmldocs" and kbuild bot.

Reported-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index 240aa3f..cf91c8e 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -233,6 +233,7 @@ struct cg_proto;
   *	@sk_ll_usec: usecs to busypoll when there is no data
   *	@sk_allocation: allocation mode
   *	@sk_pacing_rate: Pacing rate (if supported by transport/packet scheduler)
+  *	@sk_max_pacing_rate: Maximum pacing rate (%SO_MAX_PACING_RATE)
   *	@sk_sndbuf: size of send buffer in bytes
   *	@sk_flags: %SO_LINGER (l_onoff), %SO_BROADCAST, %SO_KEEPALIVE,
   *		   %SO_OOBINLINE settings, %SO_TIMESTAMPING settings
