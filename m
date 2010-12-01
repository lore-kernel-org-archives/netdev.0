From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] sched: use xps information for qdisc NUMA
 affinity
Date: Wed, 01 Dec 2010 12:49:25 -0800 (PST)
Message-ID: <20101201.124925.200368461.davem@davemloft.net>
References: <alpine.DEB.2.00.1011211501430.14906@pokey.mtv.corp.google.com>
	<1290705163.4274.12.camel@localhost>
	<1291054477.3435.1302.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47109
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756002Ab0LAUs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 15:48:58 -0500
In-Reply-To: <1291054477.3435.1302.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 29 Nov 2010 19:14:37 +0100

> [PATCH net-next-2.6] sched: use xps information for qdisc NUMA affinity
> 
> Allocate qdisc memory according to NUMA properties of cpus included in
> xps map.
> 
> To be effective, qdisc should be (re)setup after changes
> of /sys/class/net/eth<n>/queues/tx-<n>/xps_cpus
> 
> I added a numa_node field in struct netdev_queue, containing NUMA node
> if all cpus included in xps_cpus share same node, else -1.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I think this is good enough to cook in net-next-2.6

Please use "net sched: " instead of just plain "sched: " in your
commit header lines so that people don't confuse such changes
with process scheduler ones :-)
