From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 02/11] openvswitch: remove duplicated include from vport-vxlan.c
Date: Sat,  2 Nov 2013 00:43:41 -0700
Message-ID: <1383378230-59624-3-git-send-email-jesse@nicira.com>
References: <1383378230-59624-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:49007 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754484Ab3KBVwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 17:52:20 -0400
Received: by mail-pb0-f42.google.com with SMTP id jt11so5680494pbb.15
        for <netdev@vger.kernel.org>; Sat, 02 Nov 2013 14:52:19 -0700 (PDT)
In-Reply-To: <1383378230-59624-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove duplicated include.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/vport-vxlan.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index a481c03..b0da394 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -29,7 +29,6 @@
 #include <net/ip.h>
 #include <net/udp.h>
 #include <net/ip_tunnels.h>
-#include <net/udp.h>
 #include <net/rtnetlink.h>
 #include <net/route.h>
 #include <net/dsfield.h>
-- 
1.8.3.2
