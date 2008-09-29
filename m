From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Patch for tbench regression.
Date: Mon, 29 Sep 2008 14:34:37 +0400
Message-ID: <20080929103437.GD14943@2ka.mipt.ru>
References: <20080928211530.GA9341@2ka.mipt.ru> <20080929031244.GA22619@gondor.apana.org.au> <20080929053605.GA21663@2ka.mipt.ru> <20080929054052.GA23600@gondor.apana.org.au> <20080929055203.GA3460@2ka.mipt.ru> <20080929064006.GA23967@gondor.apana.org.au> <20080929064518.GA10653@2ka.mipt.ru> <20080929070213.GA24146@gondor.apana.org.au> <20080929094352.GA25273@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	Mel Gorman <mel@csn.ul.ie>, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@marvell.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:54706 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750909AbYI2KgY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2008 06:36:24 -0400
Content-Disposition: inline
In-Reply-To: <20080929094352.GA25273@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 05:43:52PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> BTW what were the actual numbers on your machine with tbench?

Do you mean real machine and not xen domain?
Here are the results:
==> /tmp/tbench/tbench-2.6.22-mainline-slab <==
Throughput 479.82 MB/sec 8 procs

==> /tmp/tbench/tbench-2.6.23-mainline <==
Throughput 454.36 MB/sec 8 procs

==> /tmp/tbench/tbench-2.6.24 <==
Throughput 399.912 MB/sec 8 procs

==> /tmp/tbench/tbench-2.6.25 <==
Throughput 391.59 MB/sec 8 procs

==> /tmp/tbench/tbench-8-2.6.26-mainline-slub <==
Throughput 398.508 MB/sec 8 procs

==> /tmp/tbench/tbench-8-2.6.27-rc7-mainline-slab <==
Throughput 366.046 MB/sec 8 procs

==> /tmp/tbench/tbench-8-2.6.27-rc7-mainline-slub <==
Throughput 360.78 MB/sec 8 procs

> And what about netperf?

Machines are dead right now, since apparently all bisections I tried are
unbootable (I gathered only one one dump in
e1000_watchdog+0x25/__netif_schedule+0xa), so I can not test anything
right now, but can run netperf when they will be alive again.

-- 
	Evgeniy Polyakov
