From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] sctp/outqueue.c: remove an unused function
Date: Fri, 29 Oct 2004 02:22:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029002201.GQ29142@stusta.de>
References: <20041028230353.GW3207@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lksctp-developers@lists.sourceforge.net, davem@davemloft.net,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: sri@us.ibm.com
Content-Disposition: inline
In-Reply-To: <20041028230353.GW3207@stusta.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[ this time without the problems due to a digital signature... ]

The patch below removes an unused function from net/sctp/outqueue.c


diffstat output:
 net/sctp/outqueue.c |   10 ----------
 1 files changed, 10 deletions(-)


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.10-rc1-mm1-full/net/sctp/outqueue.c.old	2004-10-28 23:52:37.000000000 +0200
+++ linux-2.6.10-rc1-mm1-full/net/sctp/outqueue.c	2004-10-28 23:52:50.000000000 +0200
@@ -98,16 +98,6 @@
 	return;
 }
 
-/* Insert a chunk behind chunk 'pos'. */
-static inline void sctp_outq_insert_data(struct sctp_outq *q,
-					 struct sctp_chunk *ch,
-					 struct sctp_chunk *pos)
-{
-	__skb_insert((struct sk_buff *)ch, (struct sk_buff *)pos->prev,
-		     (struct sk_buff *)pos, pos->list);
-	q->out_qlen += ch->skb->len;
-}
-
 /*
  * SFR-CACC algorithm:
  * D) If count_of_newacks is greater than or equal to 2
