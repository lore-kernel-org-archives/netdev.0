From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 6/9 net-next] af_packet: replace if/BUG by BUG_ON
Date: Mon, 30 Mar 2015 23:13:14 +0200
Message-ID: <1427749998-28464-6-git-send-email-fabf@skynet.be>
References: <1427749998-28464-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427749998-28464-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/packet/af_packet.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 5102c3c..fb94c39 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -547,8 +547,7 @@ static void prb_setup_retire_blk_timer(struct packet_sock *po, int tx_ring)
 {
 	struct tpacket_kbdq_core *pkc;
 
-	if (tx_ring)
-		BUG();
+	BUG_ON(tx_ring);
 
 	pkc = tx_ring ? GET_PBDQC_FROM_RB(&po->tx_ring) :
 			GET_PBDQC_FROM_RB(&po->rx_ring);
-- 
1.9.1
