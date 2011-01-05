From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] net_sched: pfifo_head_drop problem
Date: Wed, 5 Jan 2011 21:52:17 +0100
Message-ID: <20110105205217.GC10322@nuttenaction>
References: <1294246850.2775.244.camel@edumazet-laptop>
 <1294259702.2723.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jarek Poplawski <jarkao2@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:60518 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752855Ab1AEUwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 15:52:19 -0500
Content-Disposition: inline
In-Reply-To: <1294259702.2723.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2011-01-05 21:35:02 [+0100]:

>My mid term suggestion would be to change things so that
>sch->bstats.bytes and sch->bstats.packets are incremented in dequeue()
>only, not at enqueue() time. We also could add drop_bytes/drop_packets
>and provide estimations of drop rates.
>
>It would be more sensible anyway for very low speeds, and big bursts.
>Right now, if we drop packets, they still are accounted in byte/packets
>abolute counters and rate estimators.
>
>Before this mid term change, this patch makes pfifo_head_drop behavior
>similar to other qdiscs in case of drops :
>Dont decrement sch->bstats.bytes and sch->bstats.packets

Thanks Stephen and Erik for spotting this bug!

>Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Hagen Paul Pfeifer <hagen@jauu.net>
