From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] openvswitch: remove duplicated include from vport-vxlan.c
Date: Mon, 23 Sep 2013 21:55:22 +0800
Message-ID: <CAPgLHd_r4p2hYiL9nnwK64vck=f=sbhWrRZr32BdeW14ae63KQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, dev@openvswitch.org,
	netdev@vger.kernel.org
To: jesse@nicira.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f48.google.com ([209.85.214.48]:53516 "EHLO
	mail-bk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753418Ab3IWNzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 09:55:23 -0400
Received: by mail-bk0-f48.google.com with SMTP id my13so1175624bkb.35
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 06:55:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove duplicated include.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/openvswitch/vport-vxlan.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 36848bd..8515c66 100644
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
