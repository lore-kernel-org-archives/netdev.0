From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: gre: fix ip6gre_err()
Date: Wed, 22 Aug 2012 22:48:54 -0700 (PDT)
Message-ID: <20120822.224854.934794176873925217.davem@davemloft.net>
References: <1345384050.5158.208.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xeb@mail.ru, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33365 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754106Ab2HWFs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 01:48:57 -0400
In-Reply-To: <1345384050.5158.208.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 19 Aug 2012 15:47:30 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> ip6gre_err() miscomputes grehlen (sizeof(ipv6h) is 4 or 8,
> not 40 as expected), and should take into account 'offset' parameter.
> 
> Also uses pskb_may_pull() to cope with some fragged skbs
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Dmitry Kozlov <xeb@mail.ru>

Applied, thanks Eric.
