From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ss: dctcp changes
Date: Fri, 08 May 2015 13:28:40 -0700
Message-ID: <1431116920.22756.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:34341 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932261AbbEHU2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 16:28:42 -0400
Received: by iedfl3 with SMTP id fl3so80850493ied.1
        for <netdev@vger.kernel.org>; Fri, 08 May 2015 13:28:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Missing space before dctcp: markers.

With dctcp, cwnd=2 is pretty common, just display cwnd value even
if cwnd has this value, it makes parsing easier.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
diff --git a/misc/ss.c b/misc/ss.c
index 46dbb39..18ac105 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1684,7 +1684,7 @@ static void tcp_stats_print(struct tcpstat *s)
 
 	if (s->mss)
 		printf(" mss:%d", s->mss);
-	if (s->cwnd && s->cwnd != 2)
+	if (s->cwnd)
 		printf(" cwnd:%d", s->cwnd);
 	if (s->ssthresh)
 		printf(" ssthresh:%d", s->ssthresh);
@@ -1692,11 +1692,11 @@ static void tcp_stats_print(struct tcpstat *s)
 	if (s->dctcp && s->dctcp->enabled) {
 		struct dctcpstat *dctcp = s->dctcp;
 
-		printf("dctcp:(ce_state:%u,alpha:%u,ab_ecn:%u,ab_tot:%u)",
+		printf(" dctcp:(ce_state:%u,alpha:%u,ab_ecn:%u,ab_tot:%u)",
 				dctcp->ce_state, dctcp->alpha, dctcp->ab_ecn,
 				dctcp->ab_tot);
 	} else if (s->dctcp) {
-		printf("dctcp:fallback_mode");
+		printf(" dctcp:fallback_mode");
 	}
 
 	if (s->send_bps)
