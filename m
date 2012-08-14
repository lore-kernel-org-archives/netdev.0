From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Cache local output routes
Date: Tue, 14 Aug 2012 14:47:29 -0700 (PDT)
Message-ID: <20120814.144729.2212634746787730897.davem@davemloft.net>
References: <50289A37.6000209@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alex.shi@intel.com
To: zheng.z.yan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38489 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004Ab2HNVr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 17:47:29 -0400
In-Reply-To: <50289A37.6000209@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yan, Zheng" <zheng.z.yan@intel.com>
Date: Mon, 13 Aug 2012 14:09:59 +0800

> Commit caacf05e5ad1abf causes big drop of UDP loop back performance.
> The cause of the regression is that we do not cache the local output
> routes. Each time we send a datagram from unconnected UDP socket,
> the kernel allocates a dst_entry and adds it to the rt_uncached_list.
> It creates lock contention on the rt_uncached_lock.
> 
> Reported-by: Alex Shi <alex.shi@intel.com>
> Signed-off-by: Yan, Zheng <zheng.z.yan@intel.com>

I was pretty sure not using 'fi' was necessary for semantic
reasons here, but I can't find any such requirement, so I've
applied this, thanks.
