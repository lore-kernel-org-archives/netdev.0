From: David Miller <davem@davemloft.net>
Subject: build test your changes!
Date: Mon, 19 Oct 2009 23:22:04 -0700 (PDT)
Message-ID: <20091019.232204.52827242.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46258
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750843AbZJTGVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 02:21:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Krishna, you add:

+static inline void sk_tx_queue_set(struct sock *sk, int tx_queue)
...
+static inline void sk_tx_queue_clear(struct sock *sk)
...
+static inline int sk_tx_queue_get(const struct sock *sk)
...
+static inline bool sk_tx_queue_recorded(const struct sock *sk)

But then in the net/core/dev.c patch you go:

+			if (sk && sk->sk_dst_cache)
+				sk_record_tx_queue(sk, queue_index);

I cannot see how you did a build test of this, it's absolutely impossible.

I'm reverting.
