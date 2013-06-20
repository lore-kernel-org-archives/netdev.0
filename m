From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] ipv6: remove a useless pr_info() in addrconf_gre_config()
Date: Thu, 20 Jun 2013 16:30:00 +0800
Message-ID: <1371717000-22295-1-git-send-email-amwang@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22028 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753983Ab3FTIwV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 04:52:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

This is debug info, should at least be pr_debug(), but given
that this code is in upstream for two years, there is no
need to keep this debugging printk any more, so just remove it.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8044912..90788a1 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2760,8 +2760,6 @@ static void addrconf_gre_config(struct net_device *dev)
 	struct inet6_dev *idev;
 	struct in6_addr addr;
 
-	pr_info("%s(%s)\n", __func__, dev->name);
-
 	ASSERT_RTNL();
 
 	if ((idev = ipv6_find_idev(dev)) == NULL) {
