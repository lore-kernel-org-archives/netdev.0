From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next 1/3] vxlan: remove the unused rcu head from struct vxlan_rdst
Date: Tue, 28 May 2013 16:35:51 +0800
Message-ID: <1369730153-11214-1-git-send-email-amwang@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30531 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933444Ab3E1IgH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 May 2013 04:36:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/vxlan.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 5ed64d4..289d79a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -97,7 +97,6 @@ struct vxlan_net {
 };
 
 struct vxlan_rdst {
-	struct rcu_head		 rcu;
 	__be32			 remote_ip;
 	__be16			 remote_port;
 	u32			 remote_vni;
-- 
1.7.7.6
