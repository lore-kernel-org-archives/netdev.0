From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 6/9] net-vlan: Convert (hw_/vlan_/wanted_)features fields from u32 type to u64.
Date: Fri, 22 Apr 2011 16:36:04 -0700
Message-ID: <1303515367-25595-7-git-send-email-maheshb@google.com>
References: <1303515367-25595-1-git-send-email-maheshb@google.com>
 <1303515367-25595-2-git-send-email-maheshb@google.com>
 <1303515367-25595-3-git-send-email-maheshb@google.com>
 <1303515367-25595-4-git-send-email-maheshb@google.com>
 <1303515367-25595-5-git-send-email-maheshb@google.com>
 <1303515367-25595-6-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:28955 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757050Ab1DVXgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 19:36:19 -0400
In-Reply-To: <1303515367-25595-6-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 net/8021q/vlan_dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index d174c31..f68a670 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -586,7 +586,7 @@ static void vlan_dev_uninit(struct net_device *dev)
 	}
 }
 
-static u32 vlan_dev_fix_features(struct net_device *dev, u32 features)
+static u64 vlan_dev_fix_features(struct net_device *dev, u64 features)
 {
 	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
 
-- 
1.7.3.1

