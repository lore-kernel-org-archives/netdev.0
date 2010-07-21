From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Subject: [PATCH 2/2] net: remove last uses of __attribute__((packed))
Date: Wed, 21 Jul 2010 17:59:58 -0300
Message-ID: <1279745998-29694-2-git-send-email-padovan@profusion.mobi>
References: <1279745998-29694-1-git-send-email-padovan@profusion.mobi>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:54211 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755949Ab0GUVAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 17:00:17 -0400
In-Reply-To: <1279745998-29694-1-git-send-email-padovan@profusion.mobi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Network code uses the __packed macro instead of __attribute__((packed)).

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
---
 include/net/mac80211.h             |    2 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 7f256e2..23e46ce 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -412,7 +412,7 @@ struct ieee80211_tx_rate {
 	s8 idx;
 	u8 count;
 	u8 flags;
-} __attribute__((packed));
+} __packed;
 
 /**
  * struct ieee80211_tx_info - skb transmit information
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 64d0875..3a43cf3 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -469,7 +469,7 @@ struct arp_payload {
 	__be32 src_ip;
 	u_int8_t dst_hw[ETH_ALEN];
 	__be32 dst_ip;
-} __attribute__ ((packed));
+} __packed;
 
 #ifdef DEBUG
 static void arp_print(struct arp_payload *payload)
-- 
1.7.1.1

