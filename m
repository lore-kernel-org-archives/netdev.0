From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 6/9] xfrm: make xfrm_dev_register static
Date: Fri, 19 May 2017 09:55:53 -0700
Message-ID: <20170519165556.483-7-sthemmin@microsoft.com>
References: <20170519165556.483-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35868 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755225AbdESQ4Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 12:56:16 -0400
Received: by mail-pf0-f173.google.com with SMTP id m17so42449423pfg.3
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 09:56:11 -0700 (PDT)
In-Reply-To: <20170519165556.483-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is only used in this file and should not be global.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/xfrm/xfrm_device.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_device.c b/net/xfrm/xfrm_device.c
index 8ec8a3fcf8d4..50ec73399b48 100644
--- a/net/xfrm/xfrm_device.c
+++ b/net/xfrm/xfrm_device.c
@@ -138,7 +138,7 @@ bool xfrm_dev_offload_ok(struct sk_buff *skb, struct xfrm_state *x)
 }
 EXPORT_SYMBOL_GPL(xfrm_dev_offload_ok);
 
-int xfrm_dev_register(struct net_device *dev)
+static int xfrm_dev_register(struct net_device *dev)
 {
 	if ((dev->features & NETIF_F_HW_ESP) && !dev->xfrmdev_ops)
 		return NOTIFY_BAD;
-- 
2.11.0
