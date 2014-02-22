From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-tcp: fastopen: fix high order allocations
Date: Sat, 22 Feb 2014 00:06:26 -0500 (EST)
Message-ID: <20140222.000626.364636476966900818.davem@davemloft.net>
References: <1392919758.2316.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46223 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484AbaBVFGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 00:06:22 -0500
In-Reply-To: <1392919758.2316.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Feb 2014 10:09:18 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> This patch fixes two bugs in fastopen :
> 
> 1) The tcp_sendmsg(...,  @size) argument was ignored.
> 
>    Code was relying on user not fooling the kernel with iovec mismatches
> 
> 2) When MTU is about 64KB, tcp_send_syn_data() attempts order-5
> allocations, which are likely to fail when memory gets fragmented.
> 
> Fixes: 783237e8daf13 ("net-tcp: Fast Open client - sending SYN-data")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
