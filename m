From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/7] tcp_cubic: make the delay threshold of HyStart less sensitive
Date: Mon, 14 Mar 2011 10:52:17 -0700
Message-ID: <20110314175439.750357121@vyatta.com>
References: <20110314175211.788224699@vyatta.com>
Cc: netdev@vger.kernel.org, Sangtae Ha <sangtae.ha@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58254 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756978Ab1CNSCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 14:02:04 -0400
Content-Disposition: inline; filename=tcp-cubic-increase-delay.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sangtae Ha <sangtae.ha@gmail.com>

Make HyStart less sensitive to abrupt delay variations due to buffer bloat.

Signed-off-by: Sangtae Ha <sangtae.ha@gmail.com>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
Reported-by: Lucas Nussbaum <lucas.nussbaum@loria.fr>

---
 net/ipv4/tcp_cubic.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

--- a/net/ipv4/tcp_cubic.c	2011-03-14 08:27:24.435852847 -0700
+++ b/net/ipv4/tcp_cubic.c	2011-03-14 08:27:29.043872578 -0700
@@ -39,7 +39,7 @@
 
 /* Number of delay samples for detecting the increase of delay */
 #define HYSTART_MIN_SAMPLES	8
-#define HYSTART_DELAY_MIN	(2U<<3)
+#define HYSTART_DELAY_MIN	(4U<<3)
 #define HYSTART_DELAY_MAX	(16U<<3)
 #define HYSTART_DELAY_THRESH(x)	clamp(x, HYSTART_DELAY_MIN, HYSTART_DELAY_MAX)
 


