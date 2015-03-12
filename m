From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add real socket cookies
Date: Wed, 11 Mar 2015 21:54:24 -0400 (EDT)
Message-ID: <20150311.215424.1161505891201473105.davem@davemloft.net>
References: <1426113035.11398.90.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150311.212112.908171202958424986.davem@davemloft.net>
	<1426123902.11398.120.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, salo@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54819 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036AbbCLBy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 21:54:29 -0400
In-Reply-To: <1426123902.11398.120.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 11 Mar 2015 18:31:42 -0700

> Yes, but remember we use RCU with SLAB_DESTROY_BY_RCU thing,
> and inet_diag_dump_one_icsk() uses RCU as well.
> 
> I wanted to be extra careful here. Note that with v2, this
> atomic_cmpxchg() wont happen unless one dump operation previously
> revealed the SYN_RECV to the world.
> 
> I have no strong opinion and definitely it is currently safe to use
> atomic64_set() here.

Ok, it's just that we've worked so hard to minimize atomics in these
paths.

I'm ok with v2 of your patch and have applied it, thanks.
