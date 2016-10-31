From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: add mtu lock check in __ip6_rt_update_pmtu
Date: Mon, 31 Oct 2016 14:25:30 -0400 (EDT)
Message-ID: <20161031.142530.817201192235773225.davem@davemloft.net>
References: <0726e9078aea71d7f6332b4639985565c5e6491b.1477649881.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55218 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S944115AbcJaSZb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 14:25:31 -0400
In-Reply-To: <0726e9078aea71d7f6332b4639985565c5e6491b.1477649881.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 28 Oct 2016 18:18:01 +0800

> Prior to this patch, ipv6 didn't do mtu lock check in ip6_update_pmtu.
> It leaded to that mtu lock doesn't really work when receiving the pkt
> of ICMPV6_PKT_TOOBIG.
> 
> This patch is to add mtu lock check in __ip6_rt_update_pmtu just as ipv4
> did in __ip_rt_update_pmtu.
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied, thank you.
