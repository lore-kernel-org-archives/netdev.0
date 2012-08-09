From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 07/14] bridge: add some comments for NETDEV_RELEASE
Date: Thu,  9 Aug 2012 23:00:19 +0800
Message-ID: <1344524426-11588-8-git-send-email-amwang@redhat.com>
References: <1344524426-11588-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>, David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51501 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030900Ab2HIPAz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 11:00:55 -0400
In-Reply-To: <1344524426-11588-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add comments on why we don't notify NETDEV_RELEASE.

Cc: David Miller <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/bridge/br_if.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

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
-- 
1.7.7.6
