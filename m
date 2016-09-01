From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] mpls: get rid of trivial returns
Date: Thu, 1 Sep 2016 08:51:07 -0700
Message-ID: <20160901085107.3ab81729@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Robert Shearman <rshearma@brocade.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35947 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755542AbcIAPwE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 11:52:04 -0400
Received: by mail-pf0-f178.google.com with SMTP id h186so32561327pfg.3
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 08:50:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

return at end of function is useless.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/mpls/af_mpls.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 5c161e7..0e4334c 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -961,9 +961,6 @@ static void mpls_ifdown(struct net_device *dev, int event)
 				RCU_INIT_POINTER(nh->nh_dev, NULL);
 		} endfor_nexthops(rt);
 	}
-
-
-	return;
 }
 
 static void mpls_ifup(struct net_device *dev, unsigned int nh_flags)
@@ -997,8 +994,6 @@ static void mpls_ifup(struct net_device *dev, unsigned int nh_flags)
 
 		ACCESS_ONCE(rt->rt_nhn_alive) = alive;
 	}
-
-	return;
 }
 
 static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
-- 
2.9.3
