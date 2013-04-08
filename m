From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip_gre: fix a possible crash in
 parse_gre_header()
Date: Mon, 08 Apr 2013 12:01:10 -0400 (EDT)
Message-ID: <20130408.120110.321621015894178290.davem@davemloft.net>
References: <1365126087.3308.17.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49103 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936542Ab3DHQBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 12:01:12 -0400
In-Reply-To: <1365126087.3308.17.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 04 Apr 2013 18:41:27 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> pskb_may_pull() can change skb->head, so we must init iph/greh after
> calling it.
> 
> Bug added in commit c54419321455 (GRE: Refactor GRE tunneling code.)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
