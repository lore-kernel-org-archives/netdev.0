From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inet: consolidate INET_TW_MATCH
Date: Thu, 03 Oct 2013 15:34:03 -0400 (EDT)
Message-ID: <20131003.153403.1713167561230772868.davem@davemloft.net>
References: <1380713390.19002.87.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38251 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754965Ab3JCTeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 15:34:06 -0400
In-Reply-To: <1380713390.19002.87.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Oct 2013 04:29:50 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> TCP listener refactoring, part 2 :
> 
> We can use a generic lookup, sockets being in whatever state, if
> we are sure all relevant fields are at the same place in all socket
> types (ESTABLISH, TIME_WAIT, SYN_RECV)
> 
> This patch removes these macros :
> 
>  inet_addrpair, inet_addrpair, tw_addrpair, tw_portpair
> 
> And adds :
> 
>  sk_portpair, sk_addrpair, sk_daddr, sk_rcv_saddr
> 
> Then, INET_TW_MATCH() is really the same than INET_MATCH()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Nice simplification, applied, thanks Eric.
