From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 09/10] vxlan: whitespace cleanup
Date: Tue,  4 Jun 2013 21:24:13 -0700
Message-ID: <1370406254-6341-9-git-send-email-stephen@networkplumber.org>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:46542 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116Ab3FEEYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 00:24:32 -0400
Received: by mail-pd0-f177.google.com with SMTP id u10so1222453pdi.22
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 21:24:31 -0700 (PDT)
In-Reply-To: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vxlan.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 664381a..a3690d4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -204,9 +204,9 @@ static struct vxlan_dev *vxlan_find_vni(struct net *net, u32 id, __be16 port)
 
 /* Fill in neighbour message in skbuff. */
 static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
-			   const struct vxlan_fdb *fdb,
-			   u32 portid, u32 seq, int type, unsigned int flags,
-			   const struct vxlan_rdst *rdst)
+			  const struct vxlan_fdb *fdb,
+			  u32 portid, u32 seq, int type, unsigned int flags,
+			  const struct vxlan_rdst *rdst)
 {
 	unsigned long now = jiffies;
 	struct nda_cacheinfo ci;
@@ -1020,7 +1020,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct flowi4 fl4;
 	__be32 dst;
 	__be16 src_port, dst_port;
-        u32 vni;
+	u32 vni;
 	__be16 df = 0;
 	__u8 tos, ttl;
 
-- 
1.7.10.4
