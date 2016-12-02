From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 3/3] Revert: "ip6_tunnel: Update skb->protocol
 to ETH_P_IPV6 in ip6_tnl_xmit()"
Date: Fri, 02 Dec 2016 12:35:11 -0500 (EST)
Message-ID: <20161202.123511.1830044973827916173.davem@davemloft.net>
References: <20161201020512.21661-1-elicooper@gmx.com>
        <20161201020512.21661-3-elicooper@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: elicooper@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37226 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752273AbcLBRfM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 12:35:12 -0500
In-Reply-To: <20161201020512.21661-3-elicooper@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cooper <elicooper@gmx.com>
Date: Thu,  1 Dec 2016 10:05:12 +0800

> This reverts commit ae148b085876fa771d9ef2c05f85d4b4bf09ce0d
> ("ip6_tunnel: Update skb->protocol to ETH_P_IPV6 in ip6_tnl_xmit()").
> 
> skb->protocol is now set in __ip_local_out() and __ip6_local_out() before
> dst_output() is called. It is no longer necessary to do it for each tunnel.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Eli Cooper <elicooper@gmx.com>

Applied.
