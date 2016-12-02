From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 2/3] ipv6: Set skb->protocol properly for local
 output
Date: Fri, 02 Dec 2016 12:34:57 -0500 (EST)
Message-ID: <20161202.123457.627565586762642775.davem@davemloft.net>
References: <20161201020512.21661-1-elicooper@gmx.com>
        <20161201020512.21661-2-elicooper@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: elicooper@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37204 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753013AbcLBRe6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 12:34:58 -0500
In-Reply-To: <20161201020512.21661-2-elicooper@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cooper <elicooper@gmx.com>
Date: Thu,  1 Dec 2016 10:05:11 +0800

> When xfrm is applied to TSO/GSO packets, it follows this path:
> 
>     xfrm_output() -> xfrm_output_gso() -> skb_gso_segment()
> 
> where skb_gso_segment() relies on skb->protocol to function properly.
> 
> This patch sets skb->protocol to ETH_P_IPV6 before dst_output() is called,
> fixing a bug where GSO packets sent through an ipip6 tunnel are dropped
> when xfrm is involved.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Eli Cooper <elicooper@gmx.com>

Applied.
