From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix tcp_md5_hash_skb_data()
Date: Tue, 14 May 2013 11:33:12 -0700 (PDT)
Message-ID: <20130514.113312.1004832430857949707.davem@davemloft.net>
References: <1368516352.32106.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mischnal@google.com, bbeck@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43547 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757894Ab3ENSdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 14:33:13 -0400
In-Reply-To: <1368516352.32106.13.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 14 May 2013 00:25:52 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> TCP md5 communications fail [1] for some devices, because sg/crypto code
> assume page offsets are below PAGE_SIZE.
> 
> This was discovered using mlx4 driver [2], but I suspect loopback
> might trigger the same bug now we use order-3 pages in tcp_sendmsg()
> 
> [1] Failure is giving following messages.
> 
> huh, entered softirq 3 NET_RX ffffffff806ad230 preempt_count 00000100,
> exited with 00000101?
> 
> [2] mlx4 driver uses order-2 pages to allocate RX frags
> 
> Reported-by: Matt Schnall <mischnal@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
