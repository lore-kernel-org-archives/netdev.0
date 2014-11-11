From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: fix IPV6_PKTINFO with v4 mapped
Date: Tue, 11 Nov 2014 15:33:32 -0500 (EST)
Message-ID: <20141111.153332.989692973627846745.davem@davemloft.net>
References: <1415670865.9613.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33246 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752591AbaKKUdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 15:33:35 -0500
In-Reply-To: <1415670865.9613.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 Nov 2014 17:54:25 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Use IS_ENABLED(CONFIG_IPV6), to enable this code if IPv6 is
> a module.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: c8e6ad0829a7 ("ipv6: honor IPV6_PKTINFO with v4 mapped addresses on sendmsg")

Applied and queued up for -stable, thanks Eric.
