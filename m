From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: cgroup: null ptr dereference in netprio
 cgroup during init
Date: Wed, 18 Jul 2012 09:39:58 -0700 (PDT)
Message-ID: <20120718.093958.816641632074995342.davem@davemloft.net>
References: <20120718152520.GG25563@hmsreliant.think-freely.org>
	<20120718.085303.2226773601811613983.davem@davemloft.net>
	<20120718163721.GH25563@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, gaofeng@cn.fujitsu.com,
	mark.d.rustad@intel.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35663 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751867Ab2GRQkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:40:03 -0400
In-Reply-To: <20120718163721.GH25563@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 18 Jul 2012 12:37:21 -0400

> On Wed, Jul 18, 2012 at 08:53:03AM -0700, David Miller wrote:
>> From: Neil Horman <nhorman@tuxdriver.com>
>> Date: Wed, 18 Jul 2012 11:25:20 -0400
>> 
>> > Yeah, I see what you mean.  Seems like what we need is to either:
>> > 1) move cgroup_init to later in the boot process.  If you're not early_init,
>> > then I don't see why the subsystem can't wait until later in the boot process
>> > (i.e. make cgroup_init a late_initcall or some such).
>> > 
>> > or
>> > 
>> > 2) Allow module based cgroups to flag themselves as needing late init after the
>> > rest of the kernel has booted.
>> 
>> These are way too complicated compared to John's currently proposed
>> fix for this recently introduced regression.
>> 
>> I want a one liner which I can prove is going to remove the crash.
>> 
>> All of this talk of rearranging initcall ordering for cgroup stuff
>> is too ambitious this late in the -rc.
>> 
> Thats a fair point. I'd still like to look into this further, as I think theres
> a more correct answer than the current proposal.

I totally agree, and such investigations can target net-next.

> But since we're looking to fix a specific problem at the end of rc:
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Thanks Neil.

John can you respin your patch with the minor change I asked for?  I'll
apply it as soon as you send it.

Thanks.
