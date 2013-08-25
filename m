From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: TSO packets automatic sizing
Date: Sat, 24 Aug 2013 22:46:44 -0400 (EDT)
Message-ID: <20130824.224644.683932175468680609.davem@davemloft.net>
References: <1377304192.8828.43.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
	vanj@google.com, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754937Ab3HYCqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Aug 2013 22:46:48 -0400
In-Reply-To: <1377304192.8828.43.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 23 Aug 2013 17:29:52 -0700

> After hearing many people over past years complaining against TSO being
> bursty or even buggy, we are proud to present automatic sizing of TSO
> packets.

Looks great.

> +	pr_debug("cwnd %u packets_out %u srtt %u -> rate = %llu bits\n",
> +		 tp->snd_cwnd, tp->packets_out,
> +		 jiffies_to_usecs(tp->srtt) >> 3, rate << 3);

I'd suggest you remove this though.
