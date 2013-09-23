From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] openvswitch: remove duplicated include from vport-gre.c
Date: Mon, 23 Sep 2013 21:56:14 +0800
Message-ID: <CAPgLHd9a3ShUcYKn9Z4ES=AcAXUmRnHBNMMpni_Ot=zZekc7kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, dev@openvswitch.org,
	netdev@vger.kernel.org
To: jesse@nicira.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f53.google.com ([209.85.214.53]:33591 "EHLO
	mail-bk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753800Ab3IWN4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 09:56:15 -0400
Received: by mail-bk0-f53.google.com with SMTP id d7so1171445bkh.40
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 06:56:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove duplicated include.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/openvswitch/vport-gre.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 21d5073..c03a964c 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -24,8 +24,6 @@
 #include <linux/if_tunnel.h>
 #include <linux/if_vlan.h>
 #include <linux/in.h>
-#include <linux/if_vlan.h>
-#include <linux/in.h>
 #include <linux/in_route.h>
 #include <linux/inetdevice.h>
 #include <linux/jhash.h>
