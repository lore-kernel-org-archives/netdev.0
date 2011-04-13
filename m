From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6] if_vlan.h: fix compile errors
Date: Wed, 13 Apr 2011 03:32:17 -0700
Message-ID: <1302690737-14524-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	jpirko@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46531 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758202Ab1DMKcg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 06:32:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following commit generates compile errors becuase vlan_untag was defined
multiple times.

    commit bcc6d47903612c3861201cc3a866fb604f26b8b2
    Author: Jiri Pirko <jpirko@redhat.com>
    Date:   Thu Apr 7 19:48:33 2011 +0000

    net: vlan: make non-hw-accel rx path similar to hw-accel

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/if_vlan.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 998b299..546d9d3 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -174,7 +174,7 @@ static inline bool vlan_do_receive(struct sk_buff **skb)
 	return false;
 }
 
-inline struct sk_buff *vlan_untag(struct sk_buff *skb)
+static inline struct sk_buff *vlan_untag(struct sk_buff *skb)
 {
 	return skb;
 }
-- 
1.7.4.2

