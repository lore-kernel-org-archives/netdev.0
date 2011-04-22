From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 8/9] net-ipv4: Convert (hw_/vlan_/wanted_)features fields from u32 type to u64.
Date: Fri, 22 Apr 2011 16:36:06 -0700
Message-ID: <1303515367-25595-9-git-send-email-maheshb@google.com>
References: <1303515367-25595-1-git-send-email-maheshb@google.com>
 <1303515367-25595-2-git-send-email-maheshb@google.com>
 <1303515367-25595-3-git-send-email-maheshb@google.com>
 <1303515367-25595-4-git-send-email-maheshb@google.com>
 <1303515367-25595-5-git-send-email-maheshb@google.com>
 <1303515367-25595-6-git-send-email-maheshb@google.com>
 <1303515367-25595-7-git-send-email-maheshb@google.com>
 <1303515367-25595-8-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:28951 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757039Ab1DVXgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 19:36:19 -0400
In-Reply-To: <1303515367-25595-8-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 net/ipv4/af_inet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index cae75ef..5bf9b0f 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1219,7 +1219,7 @@ out:
 	return err;
 }
 
-static struct sk_buff *inet_gso_segment(struct sk_buff *skb, u32 features)
+static struct sk_buff *inet_gso_segment(struct sk_buff *skb, u64 features)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	struct iphdr *iph;
-- 
1.7.3.1

