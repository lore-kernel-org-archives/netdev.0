From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 2/4] net-next: dsa: add 802.3 protocol offset to struct dsa_device_ops
Date: Fri, 21 Jul 2017 10:58:11 +0200
Message-ID: <20170721085813.30789-2-john@phrozen.org>
References: <20170721085813.30789-1-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170721085813.30789-1-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding these 2 new fields allows a DSA device to indicate the offsets of
the 802.3 header caused by the insertion of the switches tag.

Signed-off-by: John Crispin <john@phrozen.org>
---
 include/net/dsa.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index a4c0d52abc80..b98bc3621905 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -106,6 +106,11 @@ struct dsa_device_ops {
 	struct sk_buff *(*rcv)(struct sk_buff *skb, struct net_device *dev,
 			       struct packet_type *pt,
 			       struct net_device *orig_dev);
+	/*
+	 * Network header and 802.3 protocol offsets
+	 */
+	int hash_nh_off;
+	int hash_proto_off;
 };
 
 struct dsa_switch_tree {
-- 
2.11.0
