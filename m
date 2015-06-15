From: Maninder Singh <maninder1.s@samsung.com>
Subject: [PATCH 1/1] net: replace if()/BUG with BUG_ON()
Date: Mon, 15 Jun 2015 10:35:05 +0530
Message-ID: <"000201d0a728$e1928230$a4b78690$@s"@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, willemb@google.com, dborkman@redhat.com,
	al.drozdov@gmail.com, viro@zeniv.linux.org.uk,
	eyal.birger@gmail.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-language: en-us
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use BUG_ON(condition) instead of if(condition)/BUG()

Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
Reviewed-by: Akhilesh Kumar <akhilesh.k@samsung.com>
---
 net/packet/af_packet.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b5989c6..c91d405 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -547,8 +547,7 @@ static void prb_setup_retire_blk_timer(struct
packet_sock *po, int tx_ring)
 {
 	struct tpacket_kbdq_core *pkc;
 
-	if (tx_ring)
-		BUG();
+	BUG_ON(tx_ring);
 
 	pkc = tx_ring ? GET_PBDQC_FROM_RB(&po->tx_ring) :
 			GET_PBDQC_FROM_RB(&po->rx_ring);
-- 
1.7.1
