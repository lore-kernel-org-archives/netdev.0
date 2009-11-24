From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter
 irqbalance hints
Date: Tue, 24 Nov 2009 09:39:56 -0800 (PST)
Message-ID: <20091124.093956.247147202.davem@davemloft.net>
References: <1258995923.4531.715.camel@laptop>
	<4B0B782A.4030901@linux.intel.com>
	<1259051986.4531.1057.camel@laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arjan@linux.intel.com, peter.p.waskiewicz.jr@intel.com,
	yong.zhang0@gmail.com, linux-kernel@vger.kernel.org,
	arjan@linux.jf.intel.com, netdev@vger.kernel.org
To: peterz@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50375
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933671AbZKXRji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 12:39:38 -0500
In-Reply-To: <1259051986.4531.1057.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 24 Nov 2009 09:39:46 +0100

> On Mon, 2009-11-23 at 22:07 -0800, Arjan van de Ven wrote:
>> the problem is that there is no way currently that the driver can communicate
>> "I allocated all my metadata on THIS numa node". irqbalance and sysadmins need
>> that to not make really stupid decisions.....
> 
> And what exactly is struct device::numa_node good for then?

device->numa_node just says where the device is.

For better performance, it can make sense to, for example, allocate the ring
buffers for different device queues on other NUMA nodes.

That's the kind of thing PJ is trying to make available.
