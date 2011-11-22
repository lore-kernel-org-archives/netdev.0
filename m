From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: Add network priority cgroup (v4)
Date: Tue, 22 Nov 2011 15:45:16 -0500 (EST)
Message-ID: <20111122.154516.228225371031125826.davem@davemloft.net>
References: <1321974652-8318-1-git-send-email-nhorman@tuxdriver.com>
	<20111122.152315.2256366823688148380.davem@davemloft.net>
	<20111122203938.GB4207@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
	robert.w.love@intel.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53713 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754696Ab1KVUq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 15:46:28 -0500
In-Reply-To: <20111122203938.GB4207@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 22 Nov 2011 15:39:38 -0500

> On Tue, Nov 22, 2011 at 03:23:15PM -0500, David Miller wrote:
>> From: Neil Horman <nhorman@tuxdriver.com>
>> Date: Tue, 22 Nov 2011 10:10:50 -0500
>> 
>> > (v2)
>> > Based on reviews from John F., Amerigo Wang and Neerav Parikh, I've cleaned up
>> > the rcu locking, fixed a memory leak in an error path, and corrected some typos.
>> > 
>> > (v3)
>> > Converted rcu_dereference to rntl_dereference where appropriate as per request
>> > from John F.
>> > 
>> > (v4)
>> > Cleaned up some spacing issues, and optimized the skb_update_priority path as
>> > per request from Dave M.
>> > 
>> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>> > Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> > CC: Robert Love <robert.w.love@intel.com>
>> > CC: "David S. Miller" <davem@davemloft.net>
>> 
>> Applied and going through some build testing now, thanks Neil.
> Thanks Dave!  I tested here building separately with:
> CONFIG_CGROUPS=n
> CONFIG_CROUPS=y && CONFIG_NETPRIO_CGROUP=y
> CONFIG_CROUPS=y && CONFIG_NETPRIO_CGROUP=m
> 
> So you should be square, but theres rarely any valid accounting for my ability
> to screw something up :)

I want to be absolutely sure, because I had to apply your changes by hand,
in particular the linux/netdevice.h changes had line offsets of up to 67.
