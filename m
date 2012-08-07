From: Cong Wang <amwang@redhat.com>
Subject: [Resend PATCH 7/8] bridge: add some comments for NETDEV_RELEASE
Date: Tue,  7 Aug 2012 13:59:09 +0800
Message-ID: <1344319149-13132-1-git-send-email-amwang@redhat.com>
References: <20120806.135003.442648448779232464.davem@davemloft.net>
Cc: Cong Wang <amwang@redhat.com>, David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44909 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751897Ab2HGF7X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2012 01:59:23 -0400
In-Reply-To: <20120806.135003.442648448779232464.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add comments on why we don't notify NETDEV_RELEASE.

Cc: David Miller <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 171fd6b..bf47d4f 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -427,6 +427,9 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 	if (!p || p->br != br)
 		return -EINVAL;
 
+	/* We don't notify NETDEV_RELEASE event, as this will
+	 * stop netconsole on the bridge.
+	 */
 	del_nbp(p);
 
 	spin_lock_bh(&br->lock);
