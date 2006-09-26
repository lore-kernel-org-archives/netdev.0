From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/3] net/ipv6: bh_lock_sock_nested on tcp_v6_rcv
Date: Mon, 25 Sep 2006 22:30:10 -0700 (PDT)
Message-ID: <20060925.223010.85417803.davem@davemloft.net>
References: <200609252343.k8PNh7DH002845@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fleite@redhat.com,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:48569
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751165AbWIZFaG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 01:30:06 -0400
To: akpm@osdl.org
In-Reply-To: <200609252343.k8PNh7DH002845@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Mon, 25 Sep 2006 16:43:07 -0700

> From: Fabio Olive Leite <fleite@redhat.com>
> 
> A while ago Ingo patched tcp_v4_rcv on net/ipv4/tcp_ipv4.c to use
> bh_lock_sock_nested and silence a lock validator warning. This fixed
> it for IPv4, but recently I saw a report of the same warning on IPv6.
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied, and pushed to -stable as well.

Thanks a lot.
