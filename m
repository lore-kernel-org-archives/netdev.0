From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter
 irqbalance hints
Date: Tue, 24 Nov 2009 09:56:52 -0800
Message-ID: <1259085412.2631.48.camel@ppwaskie-mobl2>
References: <1258995923.4531.715.camel@laptop>
	 <4B0B782A.4030901@linux.intel.com>	<1259051986.4531.1057.camel@laptop>
	 <20091124.093956.247147202.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "peterz@infradead.org" <peterz@infradead.org>,
	"arjan@linux.intel.com" <arjan@linux.intel.com>,
	"yong.zhang0@gmail.com" <yong.zhang0@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933742AbZKXR4n@vger.kernel.org>
In-Reply-To: <20091124.093956.247147202.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-11-24 at 09:39 -0800, David Miller wrote:
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Tue, 24 Nov 2009 09:39:46 +0100
> 
> > On Mon, 2009-11-23 at 22:07 -0800, Arjan van de Ven wrote:
> >> the problem is that there is no way currently that the driver can communicate
> >> "I allocated all my metadata on THIS numa node". irqbalance and sysadmins need
> >> that to not make really stupid decisions.....
> > 
> > And what exactly is struct device::numa_node good for then?
> 
> device->numa_node just says where the device is.
> 
> For better performance, it can make sense to, for example, allocate the ring
> buffers for different device queues on other NUMA nodes.
> 
> That's the kind of thing PJ is trying to make available.

Yes, that's exactly what I'm trying to do.  Even further, we want to
allocate the ring SW struct itself and descriptor structures on other
NUMA nodes, and make sure the interrupt lines up with those allocations.

Cheers,
-PJ
