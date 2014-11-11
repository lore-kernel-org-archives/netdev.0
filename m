From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: kill netif_copy_real_num_queues()
Date: Tue, 11 Nov 2014 16:30:57 -0500 (EST)
Message-ID: <20141111.163057.133311799307675036.davem@davemloft.net>
References: <1415741382-7851-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33865 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbaKKVbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 16:31:00 -0500
In-Reply-To: <1415741382-7851-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 11 Nov 2014 13:29:42 -0800

> vlan was the only user of netif_copy_real_num_queues(),
> but it no longer calls it after
> commit 4af429d29b341bb1735f04c2fb960178 ("vlan: lockless transmit path").
> So we can just remove it.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
