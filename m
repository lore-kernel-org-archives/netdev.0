From: Joe Perches <joe@perches.com>
Subject: [PATCH 02/15] stmmac: Remove duplicate unlikely from IS_ERR
Date: Thu,  9 Dec 2010 12:03:55 -0800
Message-ID: <6ab3aedcd80e5c5b3c67194975082183b6c9bda3.1291923889.git.joe@perches.com>
References: <1291906801-1389-2-git-send-email-tklauser@distanz.ch>
Cc: Jiri Kosina <trivial@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291906801-1389-2-git-send-email-tklauser@distanz.ch>
In-Reply-To: <cover.1291923888.git.joe@perches.com>
References: <cover.1291923888.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IS_ERR already uses unlikely, remove unlikely from the call sites.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/stmmac/stmmac_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index c0dc785..20f803d 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -949,7 +949,7 @@ static int stmmac_sw_tso(struct stmmac_priv *priv, struct sk_buff *skb)
 	       skb, skb->len);
 
 	segs = skb_gso_segment(skb, priv->dev->features & ~NETIF_F_TSO);
-	if (unlikely(IS_ERR(segs)))
+	if (IS_ERR(segs))
 		goto sw_tso_end;
 
 	do {
-- 
1.7.3.3.464.gf80b6
