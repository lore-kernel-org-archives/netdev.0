From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: cgroup: fix out of bounds accesses
Date: Mon, 9 Jul 2012 08:13:50 -0400
Message-ID: <20120709121350.GC9186@hmsreliant.think-freely.org>
References: <1341819910.3265.2106.camel@edumazet-glaptop>
 <20120709110154.GB9186@hmsreliant.think-freely.org>
 <1341834652.3265.2642.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, lizefan@huawei.com, tj@kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1341834652.3265.2642.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 09, 2012 at 01:50:52PM +0200, Eric Dumazet wrote:
> On Mon, 2012-07-09 at 07:01 -0400, Neil Horman wrote:
> 
> > Thank you for doing this Eric, Gao.  Just to be sure (I asked in the previous
> > thread), would it be better to avoid the length check in skb_update_prio, and
> > instead update the netdev tables to be long enough in cgrp_create and in
> > netprio_device_event on device registration?
> 
> Yes probably, and it is even needed because extend_netdev_table() can
> acutally fail to expand the table if kzalloc() returned NULL.
> 
> Current code just ignores this allocation failure so we also can crash
> in write_priomap()
> 
ACK, can you follow up with a patch please?

Thanks!
Neil

> 
> 
> 
