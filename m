From: Colin King <colin.king@canonical.com>
Subject: [PATCH][net-next] net: dsa: make function ksz_rcv static
Date: Thu,  1 Jun 2017 13:22:42 +0100
Message-ID: <20170601122242.14341-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Woojung Huh <Woojung.Huh@microchip.com>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

function ksz_rcv can be made static as it does not need to be
in global scope. Reformat arguments to make it checkpatch warning
free too.

Cleans up sparse warning: "symbol 'ksz_rcv' was not declared. Should
it be static?"

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/dsa/tag_ksz.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
index 0b08a40b493a..dfcd2fff5b13 100644
--- a/net/dsa/tag_ksz.c
+++ b/net/dsa/tag_ksz.c
@@ -72,8 +72,9 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
 	return nskb;
 }
 
-struct sk_buff *ksz_rcv(struct sk_buff *skb, struct net_device *dev,
-			struct packet_type *pt, struct net_device *orig_dev)
+static struct sk_buff *ksz_rcv(struct sk_buff *skb, struct net_device *dev,
+			       struct packet_type *pt,
+			       struct net_device *orig_dev)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_switch *ds;
-- 
2.11.0
