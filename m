From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH] if_vlan: fix vlaue -> value typo
Date: Wed, 27 May 2015 21:07:26 -0400
Message-ID: <1432775246-12938-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Patrick McHardy <kaber@trash.net>, linux-kernel@vger.kernel.org,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes "vlaue" for "value" in include/linux/if_vlan.h.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/linux/if_vlan.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index b9ab677..a40d298 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -416,7 +416,7 @@ static inline void __vlan_hwaccel_put_tag(struct sk_buff *skb,
 /**
  * __vlan_get_tag - get the VLAN ID that is part of the payload
  * @skb: skbuff to query
- * @vlan_tci: buffer to store vlaue
+ * @vlan_tci: buffer to store value
  *
  * Returns error if the skb is not of VLAN type
  */
@@ -435,7 +435,7 @@ static inline int __vlan_get_tag(const struct sk_buff *skb, u16 *vlan_tci)
 /**
  * __vlan_hwaccel_get_tag - get the VLAN ID that is in @skb->cb[]
  * @skb: skbuff to query
- * @vlan_tci: buffer to store vlaue
+ * @vlan_tci: buffer to store value
  *
  * Returns error if @skb->vlan_tci is not set correctly
  */
@@ -456,7 +456,7 @@ static inline int __vlan_hwaccel_get_tag(const struct sk_buff *skb,
 /**
  * vlan_get_tag - get the VLAN ID from the skb
  * @skb: skbuff to query
- * @vlan_tci: buffer to store vlaue
+ * @vlan_tci: buffer to store value
  *
  * Returns error if the skb is not VLAN tagged
  */
-- 
2.4.1
