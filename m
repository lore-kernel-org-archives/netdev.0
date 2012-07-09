From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cgroup: fix out of bounds accesses
Date: Mon, 09 Jul 2012 14:51:25 -0700 (PDT)
Message-ID: <20120709.145125.1903343847210013668.davem@davemloft.net>
References: <1341819910.3265.2106.camel@edumazet-glaptop>
	<4FFA9321.4030407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, nhorman@tuxdriver.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lizefan@huawei.com, tj@kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FFA9321.4030407@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Mon, 09 Jul 2012 16:15:29 +0800

> 于 2012年07月09日 15:45, Eric Dumazet 写道:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> dev->priomap is allocated by extend_netdev_table() called from
>> update_netdev_tables().
>> And this is only called if write_priomap() is called.
>> 
>> But if write_priomap() is not called, it seems we can have out of bounds
>> accesses in cgrp_destroy(), read_priomap() & skb_update_prio()
>> 
>> With help from Gao Feng
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Neil Horman <nhorman@tuxdriver.com>
>> Cc: Gao feng <gaofeng@cn.fujitsu.com>
>> ---
>> net/core/dev.c            |    8 ++++++--
>> net/core/netprio_cgroup.c |    4 ++--
>> 2 files changed, 8 insertions(+), 4 deletions(-)
> 
> Acked-by: Gao feng <gaofeng@cn.fujitsu.com>

Applied.
