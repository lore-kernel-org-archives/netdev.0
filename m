From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] af_packet: remove a stray tab in packet_set_ring()
Date: Tue, 18 Feb 2014 15:20:51 +0300
Message-ID: <20140218122050.GB9604@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>, Phil Sutter <phil@nwl.cc>,
	Atzm Watanabe <atzm@stratosphere.co.jp>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At first glance it looks like there is a missing curly brace but
actually the code works the same either way.  I have adjusted the
indenting but left the code the same.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 6a2bb37506c5..7fd37de503d1 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3786,7 +3786,7 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 		 */
 			if (!tx_ring)
 				init_prb_bdqc(po, rb, pg_vec, req_u, tx_ring);
-				break;
+			break;
 		default:
 			break;
 		}
