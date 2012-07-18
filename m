From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Statically initialize init_net.dev_base_head
Date: Wed, 18 Jul 2012 13:20:10 -0700 (PDT)
Message-ID: <20120718.132010.1765790775051953381.davem@davemloft.net>
References: <20120718190607.22923.77935.stgit@host1-mdrustad.localdomain>
	<20120718201149.GB22057@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mark.d.rustad@intel.com, netdev@vger.kernel.org,
	gaofeng@cn.fujitsu.com, eric.dumazet@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37901 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753352Ab2GRUUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 16:20:11 -0400
In-Reply-To: <20120718201149.GB22057@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 18 Jul 2012 16:11:49 -0400

> On Wed, Jul 18, 2012 at 12:06:07PM -0700, Mark Rustad wrote:
>> This change eliminates an initialization-order hazard most
>> recently seen when netprio_cgroup is built into the kernel.
>> 
>> With thanks to Eric Dumazet for catching a bug.
>> 
>> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
 ...
> I think dave was going to take John Fastabends patch from earlier today, but
> this works just as well.  Long term I'm going to look into delaying
> initzlization for cgroups, as it creates a strange initialization state when you
> have a module_init routine registered.

Neil, any particular preference between John's and Mark's version
of the fix?
