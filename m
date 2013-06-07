From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: vlan: minor: remove unused HAVE_VLAN_PUT_TAG
Date: Fri,  7 Jun 2013 02:08:31 +0200
Message-ID: <1370563711-19636-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13326 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752521Ab3FGAIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jun 2013 20:08:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the definition of HAVE_VLAN_PUT_TAG since it's not
used or exported anywhere.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/if_vlan.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 52bd03b..7a9c8cf 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -243,8 +243,6 @@ static inline struct sk_buff *__vlan_hwaccel_put_tag(struct sk_buff *skb,
 	return skb;
 }
 
-#define HAVE_VLAN_PUT_TAG
-
 /**
  * vlan_put_tag - inserts VLAN tag according to device features
  * @skb: skbuff to tag
-- 
1.7.11.7
