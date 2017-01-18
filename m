From: Lance Richardson <lrichard@redhat.com>
Subject: [PATCH net-next] vxlan: preserve type of dst_port parm for encap_bypass_if_local()
Date: Wed, 18 Jan 2017 15:24:57 -0500
Message-ID: <1484771097-5692-1-git-send-email-lrichard@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48726 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752754AbdARUel (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 15:34:41 -0500
Received: from smtp.corp.redhat.com (int-mx16.intmail.prod.int.phx2.redhat.com [10.5.11.28])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 23368C05B1D3
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 20:24:59 +0000 (UTC)
Received: from thinkcentre.redhat.com (ovpn-116-133.rdu2.redhat.com [10.10.116.133])
        by smtp.corp.redhat.com (Postfix) with ESMTP id D42F2B7F8B
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 20:24:58 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eliminate sparse warning by maintaining type of dst_port
as __be16.

Signed-off-by: Lance Richardson <lrichard@redhat.com>
---
 drivers/net/vxlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ca7196c..19b1653 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1951,7 +1951,7 @@ static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 
 static int encap_bypass_if_local(struct sk_buff *skb, struct net_device *dev,
 				 struct vxlan_dev *vxlan, union vxlan_addr *daddr,
-				 __be32 dst_port, __be32 vni, struct dst_entry *dst,
+				 __be16 dst_port, __be32 vni, struct dst_entry *dst,
 				 u32 rt_flags)
 {
 #if IS_ENABLED(CONFIG_IPV6)
-- 
2.5.5
