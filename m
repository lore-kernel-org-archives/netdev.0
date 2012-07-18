From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: cgroup: null ptr dereference in netprio
 cgroup during init
Date: Wed, 18 Jul 2012 08:53:03 -0700 (PDT)
Message-ID: <20120718.085303.2226773601811613983.davem@davemloft.net>
References: <20120718124539.GC25563@hmsreliant.think-freely.org>
	<5006C679.2040605@intel.com>
	<20120718152520.GG25563@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, gaofeng@cn.fujitsu.com,
	mark.d.rustad@intel.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34928 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752131Ab2GRPxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 11:53:16 -0400
In-Reply-To: <20120718152520.GG25563@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 18 Jul 2012 11:25:20 -0400

> Yeah, I see what you mean.  Seems like what we need is to either:
> 1) move cgroup_init to later in the boot process.  If you're not early_init,
> then I don't see why the subsystem can't wait until later in the boot process
> (i.e. make cgroup_init a late_initcall or some such).
> 
> or
> 
> 2) Allow module based cgroups to flag themselves as needing late init after the
> rest of the kernel has booted.

These are way too complicated compared to John's currently proposed
fix for this recently introduced regression.

I want a one liner which I can prove is going to remove the crash.

All of this talk of rearranging initcall ordering for cgroup stuff
is too ambitious this late in the -rc.
