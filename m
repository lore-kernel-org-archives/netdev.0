From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] igmp: hash a hash table to speedup
 ip_check_mc_rcu()
Date: Wed, 12 Jun 2013 00:26:00 -0700 (PDT)
Message-ID: <20130612.002600.1208990113757072007.davem@davemloft.net>
References: <1370565301.24311.396.camel@edumazet-glaptop>
	<20130607144833.GB2995@sbohrermbp13-local.rgmadvisors.com>
	<1370620137.24311.433.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbohrer@rgmadvisors.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50996 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280Ab3FLH0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 03:26:01 -0400
In-Reply-To: <1370620137.24311.433.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 07 Jun 2013 08:48:57 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> After IP route cache removal, multicast applications using
> a lot of multicast addresses hit a O(N) behavior in ip_check_mc_rcu()
> 
> Add a per in_device hash table to get faster lookup.
> 
> This hash table is created only if the number of items in mc_list is
> above 4.
> 
> Reported-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
