From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: mpls: Fix setting ttl_propagate for rt2
Date: Thu, 23 Mar 2017 19:02:27 -0600
Message-ID: <20170324010227.45375-1-dsa@cumulusnetworks.com>
Cc: rshearma@brocade.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35320 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934663AbdCXBCc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 21:02:32 -0400
Received: by mail-pf0-f172.google.com with SMTP id 20so194417pfk.2
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 18:02:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix copy and paste error setting rt_ttl_propagate.

Fixes: 5b441ac8784c1 ("mpls: allow TTL propagation to IP packets to be configured")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 82589b2abf3c..cd8be8d5e4ad 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -1949,7 +1949,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 		RCU_INIT_POINTER(rt2->rt_nh->nh_dev, lo);
 		rt2->rt_protocol = RTPROT_KERNEL;
 		rt2->rt_payload_type = MPT_IPV6;
-		rt0->rt_ttl_propagate = MPLS_TTL_PROP_DEFAULT;
+		rt2->rt_ttl_propagate = MPLS_TTL_PROP_DEFAULT;
 		rt2->rt_nh->nh_via_table = NEIGH_LINK_TABLE;
 		rt2->rt_nh->nh_via_alen = lo->addr_len;
 		memcpy(__mpls_nh_via(rt2, rt2->rt_nh), lo->dev_addr,
-- 
2.10.1 (Apple Git-78)
