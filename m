From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sch_gred: prefer GFP_KERNEL allocations
Date: Fri, 16 Dec 2011 15:41:17 -0500 (EST)
Message-ID: <20111216.154117.606081273063232714.davem@davemloft.net>
References: <1324022985.2562.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58514 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332Ab1LPUlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 15:41:20 -0500
In-Reply-To: <1324022985.2562.39.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 16 Dec 2011 09:09:45 +0100

> In control path, its better to use GFP_KERNEL allocations where
> possible.
> 
> Before taking qdisc spinlock, we preallocate memory just in case we'll
> need it in gred_change_vq()
> 
> This is a followup to commit 3f1e6d3fd37b (sch_gred: should not use
> GFP_KERNEL while holding a spinlock)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
