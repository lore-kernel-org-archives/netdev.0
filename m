From: "David S. Miller" <davem@redhat.com>
Subject: Fw: [PATCH][2.6] propogate rx errors from raw_rcv_skb
Date: Wed, 16 Jul 2003 19:53:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030716195345.21b9b9fc.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: zwane@arm.linux.org.uk
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Forwarded...

Zwane, please posting networking patches to the "networking"
lists, thanks.

Begin forwarded message:

Date: Wed, 16 Jul 2003 22:46:59 -0400 (EDT)
From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: "David S. Miller" <davem@redhat.com>
Subject: [PATCH][2.6] propogate rx errors from raw_rcv_skb


Hi David,
	This looks somewhat sane, ipv6 doesn't seem to need it as it 
always returns 0

Index: linux-2.6.0-test1-mm1/net/ipv4/raw.c
===================================================================
RCS file: /build/cvsroot/linux-2.6.0-test1-mm1/net/ipv4/raw.c,v
retrieving revision 1.1.1.1
diff -u -p -B -r1.1.1.1 raw.c
--- linux-2.6.0-test1-mm1/net/ipv4/raw.c	16 Jul 2003 06:37:19 -0000	1.1.1.1
+++ linux-2.6.0-test1-mm1/net/ipv4/raw.c	16 Jul 2003 16:11:50 -0000
@@ -252,8 +252,7 @@ int raw_rcv(struct sock *sk, struct sk_b
 
 	skb_push(skb, skb->data - skb->nh.raw);
 
-	raw_rcv_skb(sk, skb);
-	return 0;
+	return raw_rcv_skb(sk, skb);
 }
 
 static int raw_send_hdrinc(struct sock *sk, void *from, int length,
