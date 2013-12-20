From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rps: NUMA flow limit allocations
Date: Thu, 19 Dec 2013 19:00:34 -0500 (EST)
Message-ID: <20131219.190034.909087024580174341.davem@davemloft.net>
References: <1387377983.19078.320.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756425Ab3LTAAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 19:00:36 -0500
In-Reply-To: <1387377983.19078.320.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Dec 2013 06:46:23 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Given we allocate memory for each cpu, we can do this
> using NUMA affinities, instead of using NUMA policies
> of the process changing flow_limit_cpu_bitmap value.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
