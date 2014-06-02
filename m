From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V6 0/2] cpumask,net: Affinity hint helper
 function
Date: Sun, 01 Jun 2014 19:17:37 -0700 (PDT)
Message-ID: <20140601.191737.1821014891784987464.davem@davemloft.net>
References: <1401029247-15196-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org,
	yevgenyp@mellanox.com, yuvala@mellanox.com,
	linux-kernel@vger.kernel.org
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55355 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438AbaFBCRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 22:17:39 -0400
In-Reply-To: <1401029247-15196-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Sun, 25 May 2014 17:47:25 +0300

> This patchset will set affinity hint to influence IRQs to be allocated on the
> same NUMA node as the one where the card resides. As discussed in
> http://www.spinics.net/lists/netdev/msg271497.html
> 
> If the number of IRQs allocated is greater than the number of local NUMA cores, all
> local cores will be used first, and the rest of the IRQs will be on a remote
> NUMA node.
> If no NUMA support - IRQ's and cores will be mapped 1:1
> 
> Since the utility function to calculate the mapping could be useful in other mq
> drivers in the kernel, it was added to cpumask.[ch]
> 
> This patchset was tested and applied on top of net-next since the first
> consumer is a network device (mlx4_en).  Over commit 506724c: "tg3: Override
> clock, link aware and link idle mode during NVRAM dump"
> 
> I couldn't find a maintainer for cpumask.c, so only added the kernel mailing
> list

Applied to net-next, thanks.
