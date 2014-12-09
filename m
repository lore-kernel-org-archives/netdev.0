From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] udp: Neaten and reduce size of
 compute_score functions
Date: Mon, 08 Dec 2014 20:29:23 -0500 (EST)
Message-ID: <20141208.202923.1673226136424442147.davem@davemloft.net>
References: <1417489141.4442.24.camel@edumazet-glaptop2.roam.corp.google.com>
	<1417489760.4894.8.camel@perches.com>
	<1417494546.4894.12.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59062 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbaLIB31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 20:29:27 -0500
In-Reply-To: <1417494546.4894.12.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 01 Dec 2014 20:29:06 -0800

> The compute_score functions are a bit difficult to read.
> 
> Neaten them a bit to reduce object sizes and make them a
> bit more intelligible.
> 
> Return early to avoid indentation and avoid unnecessary
> initializations.
> 
> (allyesconfig, but w/ -O2 and no profiling)
> 
> $ size net/ipv[46]/udp.o.*
>    text    data     bss     dec     hex filename
>   28680    1184      25   29889    74c1 net/ipv4/udp.o.new
>   28756    1184      25   29965    750d net/ipv4/udp.o.old
>   17600    1010       2   18612    48b4 net/ipv6/udp.o.new
>   17632    1010       2   18644    48d4 net/ipv6/udp.o.old
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
