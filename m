From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 2/2] bridge: display IFLA_BRPORT_UNICAST_FLOOD value
Date: Tue, 20 May 2014 11:37:30 +0200
Message-ID: <1400578650-6917-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1400578650-6917-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:45243 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbaETJht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 05:37:49 -0400
In-Reply-To: <1400578650-6917-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 bridge/link.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/bridge/link.c b/bridge/link.c
index 1632bc16803f..ca4a6023251f 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -188,6 +188,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
 				if (prtb[IFLA_BRPORT_LEARNING])
 					print_onoff(fp, "learning",
 						    rta_getattr_u8(prtb[IFLA_BRPORT_LEARNING]));
+				if (prtb[IFLA_BRPORT_UNICAST_FLOOD])
+					print_onoff(fp, "unicast_flood",
+						    rta_getattr_u8(prtb[IFLA_BRPORT_UNICAST_FLOOD]));
 			}
 		} else
 			print_portstate(fp, rta_getattr_u8(tb[IFLA_PROTINFO]));
-- 
1.9.0
