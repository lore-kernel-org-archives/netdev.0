From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] ovs: set name assign type of internal port
Date: Tue, 31 May 2016 13:41:02 +0000
Message-ID: <1464702062-7220-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:2883 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753247AbcEaMzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 08:55:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set name_assign_type of internal port to NET_NAME_USER.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 net/openvswitch/vport-internal_dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 2ee48e4..434e04c 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -195,7 +195,7 @@ static struct vport *internal_dev_create(const struct vport_parms *parms)
 	}
 
 	vport->dev = alloc_netdev(sizeof(struct internal_dev),
-				  parms->name, NET_NAME_UNKNOWN, do_setup);
+				  parms->name, NET_NAME_USER, do_setup);
 	if (!vport->dev) {
 		err = -ENOMEM;
 		goto error_free_vport;
-- 
1.8.3.1
