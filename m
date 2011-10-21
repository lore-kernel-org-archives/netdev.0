From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] tcp: add const qualifiers where possible
Date: Fri, 21 Oct 2011 05:31:47 -0400 (EDT)
Message-ID: <20111021.053147.1778118777108428234.davem@davemloft.net>
References: <20111021.033648.1029307040209750463.davem@davemloft.net>
	<1319185263.2338.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1319187493.2338.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54713 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596Ab1JUJbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 05:31:52 -0400
In-Reply-To: <1319187493.2338.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 21 Oct 2011 10:58:13 +0200

> Adding const qualifiers to pointers can ease code review, and spot some
> bugs. It might allow compiler to optimize code further.
> 
> For example, is it legal to temporary write a null cksum into tcphdr
> in tcp_md5_hash_header() ? I am afraid a sniffer could catch the
> temporary null value...
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> V2: no need to change __sk_dst_get() prototype...

Applied.
