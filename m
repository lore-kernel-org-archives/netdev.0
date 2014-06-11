From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V7 0/2] cpumask,net: affinity hint helper
 function
Date: Wed, 11 Jun 2014 14:59:38 -0700 (PDT)
Message-ID: <20140611.145938.2160468514837164249.davem@davemloft.net>
References: <1402298679-22038-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, yuvala@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47431 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199AbaFKV7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 17:59:42 -0400
In-Reply-To: <1402298679-22038-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Mon,  9 Jun 2014 10:24:37 +0300

> This patchset will set affinity hint to influence IRQs to be allocated on the
> same NUMA node as the one where the card resides. As discussed in
> http://www.spinics.net/lists/netdev/msg271497.html
> 
> If number of IRQs allocated is greater than the number of local NUMA cores, all
> local cores will be used first, and the rest of the IRQs will be on a remote
> NUMA node.
> If no NUMA support - IRQ's and cores will be mapped 1:1
> 
> Since the utility function to calculate the mapping could be useful in other mq
> drivers in the kernel, it was added to cpumask.[ch]
> 
> This patchset was tested and applied on top of net-next since the first
> consumer is a network device (mlx4_en).  Over commit fff1f59 "mac802154:
> llsec: add forgotten list_del_rcu in key removal"

Series applied, thanks.
