From: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Subject: [PATCH]: fixed typo of reassembly.c
Date: Thu, 30 Sep 2004 19:23:26 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409301023.i8UANRGp002783@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

This patch fixes byte ordering. Please apply this.

Signed-off-by: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>

Regards,

diff -X dontdiff -Nurp linux-2.6.9-rc3/net/ipv6/reassembly.c linux-2.6.9-rc3-fixed/net/ipv6/reassembly.c
--- linux-2.6.9-rc3/net/ipv6/reassembly.c	2004-09-30 18:45:24.014851224 +0900
+++ linux-2.6.9-rc3-fixed/net/ipv6/reassembly.c	2004-09-30 18:51:58.019953344 +0900
@@ -665,7 +665,7 @@ static int ip6_frag_reasm(struct frag_qu
 	head->next = NULL;
 	head->dev = dev;
 	head->stamp = fq->stamp;
-	head->nh.ipv6h->payload_len = ntohs(payload_len);
+	head->nh.ipv6h->payload_len = htons(payload_len);
 
 	*skb_in = head;
 
-----------------------------------------------------------------
Yasuyuki KOZAKAI @ USAGI Project <yasuyuki.kozakai@toshiba.co.jp>
