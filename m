From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 11/12] vxlan whitespace cleanup
Date: Mon, 10 Jun 2013 13:24:38 -0700
Message-ID: <20130610132438.244ff5e7@nehalam.linuxnetplumber.net>
References: <20130610200524.721617349@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	David L Stevens <dlstevens@us.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:47820 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599Ab3FJUZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 16:25:45 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so2192622pbc.7
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 13:25:45 -0700 (PDT)
In-Reply-To: <20130610200524.721617349@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Acked-by: David L Stevens <dlstevens@us.ibm.com>

--- a/drivers/net/vxlan.c	2013-06-10 12:20:04.266038079 -0700
+++ b/drivers/net/vxlan.c	2013-06-10 12:20:04.974030028 -0700
@@ -210,9 +210,9 @@ static struct vxlan_dev *vxlan_find_vni(
 
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
@@ -1032,7 +1032,7 @@ static void vxlan_xmit_one(struct sk_buf
 	struct flowi4 fl4;
 	__be32 dst;
 	__be16 src_port, dst_port;
-        u32 vni;
+	u32 vni;
 	__be16 df = 0;
 	__u8 tos, ttl;
 
