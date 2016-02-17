From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: add tcpi_min_rtt and tcpi_notsent_bytes
 to tcp_info
Date: Tue, 16 Feb 2016 20:28:07 -0500 (EST)
Message-ID: <20160216.202807.2176931987212796992.davem@davemloft.net>
References: <1455256973.18740.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42584 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933587AbcBQB2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 20:28:09 -0500
In-Reply-To: <1455256973.18740.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 11 Feb 2016 22:02:53 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> tcpi_min_rtt reports the minimal rtt observed by TCP stack for the flow,
> in usec unit. Might be ~0U if not yet known.
> 
> tcpi_notsent_bytes reports the amount of bytes in the write queue that
> were not yet sent.
> 
> This is done in a single patch to not add a temporary 32bit padding hole
> in tcp_info.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
