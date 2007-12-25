From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Subject: [patch] skbuff: spelling and formatting fixes
Date: Tue, 25 Dec 2007 07:59:16 +0100 (CET)
Message-ID: <537476.77850.qm@web52009.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, trivial@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52009.mail.re2.yahoo.com ([206.190.48.58]:38789 "HELO
	web52009.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750891AbXLYG7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2007 01:59:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--- a/include/linux/skbuff.h	2007-12-25
08:24:51.032348500 +0200
+++ b/include/linux/skbuff.h	2007-12-25
08:38:31.067753500 +0200
@@ -127,7 +127,7 @@ struct sk_buff_head {
 struct sk_buff;
=20
 /* To allow 64K frame to be packed as single skb
without frag_list */
-#define MAX_SKB_FRAGS (65536/PAGE_SIZE + 2)
+#define MAX_SKB_FRAGS ((65536 / PAGE_SIZE) + 2)
=20
 typedef struct skb_frag_struct skb_frag_t;
=20
@@ -394,7 +394,7 @@ static inline void
skb_truesize_check(st
=20
 extern int skb_append_datato_frags(struct sock *sk,
struct sk_buff *skb,
 			int getfrag(void *from, char *to, int offset,
-			int len,int odd, struct sk_buff *skb),
+					int len, int odd, struct sk_buff *skb),
 			void *from, int length);
=20
 struct skb_seq_state
@@ -1346,7 +1346,7 @@ static inline struct sk_buff
*netdev_all
  *	@len: length up to which to write
  *
  *	Returns true if modifying the header part of the
cloned buffer
- *	does not requires the data to be copied.
+ *	does not require the data to be copied.
  */
 static inline int skb_clone_writable(struct sk_buff
*skb, unsigned int len)
 {



       __________________________________ Ihr erstes Fernweh? Wo gibt e=
s den sch=F6nsten Strand? www.yahoo.de/clever
