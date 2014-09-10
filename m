From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/5] atm: Convert pr_warning to pr_warn
Date: Tue,  9 Sep 2014 21:17:28 -0700
Message-ID: <43f9ed4e89db6bdc47354a595d416e773de7628c.1410322181.git.joe@perches.com>
References: <cover.1410322181.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1410322181.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the more common pr_warn.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/clip.c   | 4 ++--
 net/atm/common.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/atm/clip.c b/net/atm/clip.c
index 4633904..1d9eaa4 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -384,7 +384,7 @@ static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
 	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n", skb, vcc, vcc->dev);
 	old = xchg(&entry->vccs->xoff, 1);	/* assume XOFF ... */
 	if (old) {
-		pr_warning("XOFF->XOFF transition\n");
+		pr_warn("XOFF->XOFF transition\n");
 		goto out_release_neigh;
 	}
 	dev->stats.tx_packets++;
@@ -447,7 +447,7 @@ static int clip_setentry(struct atm_vcc *vcc, __be32 ip)
 	struct rtable *rt;
 
 	if (vcc->push != clip_push) {
-		pr_warning("non-CLIP VCC\n");
+		pr_warn("non-CLIP VCC\n");
 		return -EBADF;
 	}
 	clip_vcc = CLIP_VCC(vcc);
diff --git a/net/atm/common.c b/net/atm/common.c
index 7b49100..6a76515 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -300,7 +300,7 @@ static int adjust_tp(struct atm_trafprm *tp, unsigned char aal)
 		max_sdu = ATM_MAX_AAL34_PDU;
 		break;
 	default:
-		pr_warning("AAL problems ... (%d)\n", aal);
+		pr_warn("AAL problems ... (%d)\n", aal);
 		/* fall through */
 	case ATM_AAL5:
 		max_sdu = ATM_MAX_AAL5_PDU;
-- 
1.8.1.2.459.gbcd45b4.dirty
