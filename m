From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next 7/7] vxlan: remove unsed vxlan_dev_dst_port()
Date: Fri,  4 Nov 2016 13:51:56 -0700
Message-ID: <1478292716-54649-8-git-send-email-pshelar@ovn.org>
References: <1478292716-54649-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:54941 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755438AbcKDUwJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 16:52:09 -0400
In-Reply-To: <1478292716-54649-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 include/net/vxlan.h | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 308adc4..49a5920 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -281,16 +281,6 @@ struct vxlan_dev {
 struct net_device *vxlan_dev_create(struct net *net, const char *name,
 				    u8 name_assign_type, struct vxlan_config *conf);
 
-static inline __be16 vxlan_dev_dst_port(struct vxlan_dev *vxlan,
-					unsigned short family)
-{
-#if IS_ENABLED(CONFIG_IPV6)
-	if (family == AF_INET6)
-		return inet_sk(vxlan->vn6_sock->sock->sk)->inet_sport;
-#endif
-	return inet_sk(vxlan->vn4_sock->sock->sk)->inet_sport;
-}
-
 static inline netdev_features_t vxlan_features_check(struct sk_buff *skb,
 						     netdev_features_t features)
 {
-- 
1.9.1
