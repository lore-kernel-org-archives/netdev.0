From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net_sched: add u64 rate to
 psched_ratecfg_precompute()
Date: Fri, 20 Sep 2013 14:42:41 -0400 (EDT)
Message-ID: <20130920.144241.1852910152833814427.davem@davemloft.net>
References: <1379607003.3282.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39330 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753563Ab3ITSmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 14:42:42 -0400
In-Reply-To: <1379607003.3282.13.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Sep 2013 09:10:03 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Add an extra u64 rate parameter to psched_ratecfg_precompute()
> so that some qdisc can opt-in for 64bit rates in the future,
> to overcome the ~34 Gbits limit.
> 
> psched_ratecfg_getrate() reports a legacy structure to
> tc utility, so if actual rate is above the 32bit rate field,
> cap it to the 34Gbit limit.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
