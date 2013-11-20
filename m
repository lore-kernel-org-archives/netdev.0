From: David Miller <davem@davemloft.net>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few
 KB/s
Date: Wed, 20 Nov 2013 13:52:21 -0500 (EST)
Message-ID: <20131120.135221.974195642039657856.davem@davemloft.net>
References: <1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131120171227.GG8581@1wt.eu>
	<1384968607.10637.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, arno@natisbad.org, xiyou.wangcong@gmail.com,
	edumazet@google.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36145 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011Ab3KTSwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 13:52:24 -0500
In-Reply-To: <1384968607.10637.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Nov 2013 09:30:07 -0800

> max (128KB , 1-2 ms) of buffering per flow should be enough to reach
> line rate, even for a single flow, but this means the sk_sndbuf value
> for the socket must take into account the pipe size _plus_ 1ms of
> buffering.

And we can implement this using the estimated pacing rate.
