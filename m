From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 27/27] net/vlan: remove unused #define
 HAVE_VLAN_GET_TAG
Date: Tue, 13 Dec 2016 01:12:43 +0100 (CET)
Message-ID: <d5b0bda522b743d26f2c7db8f29393891c801916.1481586602.git.mirq-linux@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:50226 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932619AbcLMAMp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 19:12:45 -0500
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 include/linux/if_vlan.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 8ff2f0e..f0b9356 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -477,8 +477,6 @@ static inline int __vlan_hwaccel_get_tag(const struct sk_buff *skb,
 	}
 }
 
-#define HAVE_VLAN_GET_TAG
-
 /**
  * vlan_get_tag - get the VLAN ID from the skb
  * @skb: skbuff to query
-- 
2.10.2
