From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] IP_GRE: Linearize skb before csum.
Date: Wed, 23 Jan 2013 00:36:19 -0500 (EST)
Message-ID: <20130123.003619.868819989744570920.davem@davemloft.net>
References: <1358917373.12374.707.camel@edumazet-glaptop>
	<20130123.001956.1988771856502410155.davem@davemloft.net>
	<1358919050.12374.733.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, pshelar@nicira.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32794 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab3AWFga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 00:36:30 -0500
In-Reply-To: <1358919050.12374.733.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Jan 2013 21:30:50 -0800

> We could add a new SKB_GSO_SHARED_FRAG bit for that, and force an extra
> copy of frags, instead of a linearize call.
> 
> Basically, splice(pipe -> socket)/sendfile()/vmsplice() should set this
> flag.

Right.

> Its a bit late here, I'll do that tomorrow.

Thank you.
