From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: take care of misalignments
Date: Mon, 05 Dec 2011 18:45:54 -0500 (EST)
Message-ID: <20111205.184554.1914078417882837206.davem@davemloft.net>
References: <1322984393.2762.134.camel@edumazet-laptop>
	<20111204.132126.654109006321344175.davem@davemloft.net>
	<1323024668.2762.163.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: subramanian.vijay@gmail.com, therbert@google.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51536 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932481Ab1LEXp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 18:45:57 -0500
In-Reply-To: <1323024668.2762.163.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 04 Dec 2011 19:51:08 +0100

> [PATCH net-next] tcp: fix tcp_trim_head()
> 
> commit f07d960df3 (tcp: avoid frag allocation for small frames)
> breaked assumption in tcp stack that skb is either linear (skb->data_len
> == 0), or fully fragged (skb->data_len == skb->len)
> 
> tcp_trim_head() made this assumption, we must fix it.
> 
> Thanks to Vijay for providing a very detailed explanation.
> 
> Reported-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
