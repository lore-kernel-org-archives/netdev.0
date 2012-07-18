From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Statically initialize init_net.dev_base_head
Date: Wed, 18 Jul 2012 13:32:57 -0700 (PDT)
Message-ID: <20120718.133257.1442231302624355994.davem@davemloft.net>
References: <20120718190607.22923.77935.stgit@host1-mdrustad.localdomain>
	<1342638809.2626.3451.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mark.d.rustad@intel.com, netdev@vger.kernel.org,
	gaofeng@cn.fujitsu.com, nhorman@tuxdriver.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755896Ab2GRUc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 16:32:58 -0400
In-Reply-To: <1342638809.2626.3451.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Jul 2012 21:13:29 +0200

> On Wed, 2012-07-18 at 12:06 -0700, Mark Rustad wrote:
>> This change eliminates an initialization-order hazard most
>> recently seen when netprio_cgroup is built into the kernel.
>> 
>> With thanks to Eric Dumazet for catching a bug.
>> 
>> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
>> ---
>> 
>>  net/core/dev.c           |    3 ++-
>>  net/core/net_namespace.c |    4 +++-
>>  2 files changed, 5 insertions(+), 2 deletions(-)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
