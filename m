From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 7/8] bridge: add some comments for NETDEV_RELEASE
Date: Mon,  6 Aug 2012 22:23:31 +0800
Message-ID: <1344263012-4031-8-git-send-email-amwang@redhat.com>
References: <1344263012-4031-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20414 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756571Ab2HFOYC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 10:24:02 -0400
In-Reply-To: <1344263012-4031-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add comments on why we don't notify NETDEV_RELEASE.

Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/bridge/br_if.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 171fd6b..910f4aa 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -427,6 +427,10 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 	if (!p || p->br != br)
 		return -EINVAL;
 
+	/*
+	 * We don't notify NETDEV_RELEASE event, as this will
+	 * stop netconsole on the bridge.
+	 */
 	del_nbp(p);
 
 	spin_lock_bh(&br->lock);
-- 
1.7.7.6
