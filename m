From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix build errors if ipv6 is disabled
Date: Wed, 09 Oct 2013 02:52:31 -0400 (EDT)
Message-ID: <20131009.025231.608686215035548132.davem@davemloft.net>
References: <1381295165.4971.7.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632Ab3JIGwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 02:52:34 -0400
In-Reply-To: <1381295165.4971.7.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 08 Oct 2013 22:06:05 -0700

> +#if IS_ENABLED(CONFIG_IPV6)
> +	if (sk->sk_family == AF_INET6 && !ipv6_addr_any(&sk->sk_v6_rcv_saddr)
> +		sk->sk_userlocks |= SOCK_BINDADDR_LOCK;
> +#endif

Would you mind testing this with ipv6 enabled again? :-/
