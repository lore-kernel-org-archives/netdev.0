From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: sctp: fix lockdep splat in sctp_v6_get_dst()
Date: Mon, 07 Dec 2015 17:07:45 -0500 (EST)
Message-ID: <20151207.170745.1345382498039990120.davem@davemloft.net>
References: <20151206013708.GA19228@codemonkey.org.uk>
	<1449366988.25029.40.camel@edumazet-glaptop2.roam.corp.google.com>
	<1449505521.25029.65.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51580 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755877AbbLGWHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 17:07:46 -0500
In-Reply-To: <1449505521.25029.65.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 07 Dec 2015 08:25:21 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> While cooking the sctp np->opt rcu fixes, I forgot to move
> one rcu_read_unlock() after the added rcu_dereference() in
> sctp_v6_get_dst()
> 
> This gave lockdep warnings reported by Dave Jones.
> 
> Fixes: c836a8ba9386 ("ipv6: sctp: add rcu protection around np->opt")
> Reported-by: Dave Jones <davej@codemonkey.org.uk>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
