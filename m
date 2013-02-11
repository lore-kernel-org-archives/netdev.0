From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] veth: fix NULL dereference in veth_dellink()
Date: Sun, 10 Feb 2013 20:43:09 -0500 (EST)
Message-ID: <20130210.204309.469190125028462852.davem@davemloft.net>
References: <1360390249.6696.22.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: erdnetdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779Ab3BKBnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 20:43:11 -0500
In-Reply-To: <1360390249.6696.22.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <erdnetdev@gmail.com>
Date: Fri, 08 Feb 2013 22:10:49 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> commit d0e2c55e7c940 (veth: avoid a NULL deref in veth_stats_one)
> added another NULL deref in veth_dellink().
> 
> # ip link add name veth1 type veth peer name veth0
> # rmmod veth
> 
> We crash because veth_dellink() is called twice, so we must
> take care of NULL peer.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
