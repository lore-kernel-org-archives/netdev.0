From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: validate_xmit_vlan() is static
Date: Mon, 06 Oct 2014 11:26:27 -0700
Message-ID: <1412619987.11091.76.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:61549 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155AbaJFS02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 14:26:28 -0400
Received: by mail-pa0-f54.google.com with SMTP id ey11so5740190pad.27
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 11:26:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Marking this as static allows compiler to inline it.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7d5691cc1f479ee4f1bb46b06d35fe8c..2702724ce2de5712e13c37321597a314 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2643,7 +2643,8 @@ out:
 	return skb;
 }
 
-struct sk_buff *validate_xmit_vlan(struct sk_buff *skb, netdev_features_t features)
+static struct sk_buff *validate_xmit_vlan(struct sk_buff *skb,
+					  netdev_features_t features)
 {
 	if (vlan_tx_tag_present(skb) &&
 	    !vlan_hw_offload_capable(features, skb->vlan_proto)) {
