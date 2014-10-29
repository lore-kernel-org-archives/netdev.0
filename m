From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] ipv4: minor spelling fixes
Date: Wed, 29 Oct 2014 16:05:06 -0700
Message-ID: <20141029160506.46011813@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:47075 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757075AbaJ2XFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 19:05:23 -0400
Received: by mail-pd0-f178.google.com with SMTP id fp1so3839846pdb.23
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 16:05:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/ipv4/geneve.c	2014-10-27 21:05:31.259174957 -0700
+++ b/net/ipv4/geneve.c	2014-10-27 21:05:31.255174943 -0700
@@ -104,7 +104,7 @@ static void geneve_build_header(struct g
 	memcpy(geneveh->options, options, options_len);
 }
 
-/* Transmit a fully formated Geneve frame.
+/* Transmit a fully formatted Geneve frame.
  *
  * When calling this function. The skb->data should point
  * to the geneve header which is fully formed.
--- a/net/ipv4/tcp_input.c	2014-10-27 21:05:31.259174957 -0700
+++ b/net/ipv4/tcp_input.c	2014-10-27 21:05:31.259174957 -0700
@@ -5865,7 +5865,7 @@ static inline void pr_drop_req(struct re
  * If we receive a SYN packet with these bits set, it means a
  * network is playing bad games with TOS bits. In order to
  * avoid possible false congestion notifications, we disable
- * TCP ECN negociation.
+ * TCP ECN negotiation.
  *
  * Exception: tcp_ca wants ECN. This is required for DCTCP
  * congestion control; it requires setting ECT on all packets,
