From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 1/1] net/vlan: remove unused #define
 HAVE_VLAN_GET_TAG
Date: Wed,  4 Jan 2017 00:55:10 +0100 (CET)
Message-ID: <838765370d41d38549a8b6bc0dce2f2a1b287214.1483487697.git.mirq-linux@rere.qmqm.pl>
References: <cover.1483487697.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:37074 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759574AbdACX4A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 18:56:00 -0500
In-Reply-To: <cover.1483487697.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 include/linux/if_vlan.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index bc4e8c2533da..74675312f8d9 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -476,8 +476,6 @@ static inline int __vlan_hwaccel_get_tag(const struct sk_buff *skb,
 	}
 }
 
-#define HAVE_VLAN_GET_TAG
-
 /**
  * vlan_get_tag - get the VLAN ID from the skb
  * @skb: skbuff to query
-- 
2.11.0
