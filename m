From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: avoid NULL deref in inet_ctl_sock_destroy()
Date: Mon, 02 Nov 2015 22:46:47 -0500 (EST)
Message-ID: <20151102.224647.1672869809835691426.davem@davemloft.net>
References: <1446479407.23275.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39146 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752306AbbKCDqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 22:46:49 -0500
In-Reply-To: <1446479407.23275.12.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Nov 2015 07:50:07 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Under low memory conditions, tcp_sk_init() and icmp_sk_init()
> can both iterate on all possible cpus and call inet_ctl_sock_destroy(),
> with eventual NULL pointer.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied.
