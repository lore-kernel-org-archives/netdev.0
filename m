From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 05/11] skbuff: Extend gso_type to unsigned int.
Date: Fri, 23 Sep 2016 09:53:42 +0200
Message-ID: <1474617228-26103-6-git-send-email-steffen.klassert@secunet.com>
References: <1474617228-26103-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>,
        "Boris Pismenny" <borisp@mellanox.com>,
        Ariel Levkovich <lariel@mellanox.com>,
        "Hay, Joshua A" <joshua.a.hay@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:46004 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758345AbcIWHyE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:54:04 -0400
In-Reply-To: <1474617228-26103-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All available gso_type flags are currently in use,
so extend gso_type to be able to add further flags.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/skbuff.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f21da42..c1fd854 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -417,7 +417,7 @@ struct skb_shared_info {
 	unsigned short	gso_size;
 	/* Warning: this field is not always filled in (UFO)! */
 	unsigned short	gso_segs;
-	unsigned short  gso_type;
+	unsigned int	gso_type;
 	struct sk_buff	*frag_list;
 	struct skb_shared_hwtstamps hwtstamps;
 	u32		tskey;
-- 
1.9.1
