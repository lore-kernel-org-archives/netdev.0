From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: icmp: use percpu allocation
Date: Sat, 31 Jan 2015 17:48:29 -0800 (PST)
Message-ID: <20150131.174829.1330137139393440175.davem@davemloft.net>
References: <1422575889.21689.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752974AbbBABsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 20:48:30 -0500
In-Reply-To: <1422575889.21689.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Jan 2015 15:58:09 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Get rid of nr_cpu_ids and use modern percpu allocation.
> 
> Note that the sockets themselves are not yet allocated
> using NUMA affinity.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
