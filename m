From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] codel: add ce_threshold attribute
Date: Sun, 10 May 2015 19:50:57 -0400 (EDT)
Message-ID: <20150510.195057.467500128068846566.davem@davemloft.net>
References: <1431122712.22756.43.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, fw@strlen.de,
	glenn.judd@morganstanley.com, nanditad@google.com,
	ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755AbbEJXu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 19:50:59 -0400
In-Reply-To: <1431122712.22756.43.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 May 2015 15:05:12 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> For DCTCP or similar ECN based deployments on fabrics with shallow
> buffers, hosts are responsible for a good part of the buffering.
> 
> This patch adds an optional ce_threshold to codel & fq_codel qdiscs,
> so that DCTCP can have feedback from queuing in the host.
> 
> A DCTCP enabled egress port simply have a queue occupancy threshold
> above which ECT packets get CE mark.
> 
> In codel language this translates to a sojourn time, so that one doesn't
> have to worry about bytes or bandwidth but delays.
> 
> This makes the host an active participant in the health of the whole
> network.
> 
> This also helps experimenting DCTCP in a setup without DCTCP compliant
> fabric.
> 
> On following example, ce_threshold is set to 1ms, and we can see from
> 'ldelay xxx us' that TCP is not trying to go around the 5ms codel
> target.
> 
> Queue has more capacity to absorb inelastic bursts (say from UDP
> traffic), as queues are maintained to an optimal level.
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks a lot Eric.
