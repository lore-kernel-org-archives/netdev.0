From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dst: no need to take reference on DST_NOCACHE
 dsts
Date: Tue, 09 Dec 2014 16:08:40 -0500 (EST)
Message-ID: <20141209.160840.1901007199176473394.davem@davemloft.net>
References: <51b54bc66109594459e1a08c9022c5c48f20d910.1417889528.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ja@ssi.bg
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbaLIVIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 16:08:42 -0500
In-Reply-To: <51b54bc66109594459e1a08c9022c5c48f20d910.1417889528.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat,  6 Dec 2014 19:19:42 +0100

> Since commit f8864972126899 ("ipv4: fix dst race in sk_dst_get()")
> DST_NOCACHE dst_entries get freed by RCU. So there is no need to get a
> reference on them when we are in rcu protected sections.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks.
