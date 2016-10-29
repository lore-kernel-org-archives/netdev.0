From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip6_tunnel: Update skb->protocol to ETH_P_IPV6 in
 ip6_tnl_xmit()
Date: Sat, 29 Oct 2016 14:50:20 -0400 (EDT)
Message-ID: <20161029.145020.331535030578639626.davem@davemloft.net>
References: <20161026021109.19277-1-elicooper@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: elicooper@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51684 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751207AbcJ2SuW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 14:50:22 -0400
In-Reply-To: <20161026021109.19277-1-elicooper@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cooper <elicooper@gmx.com>
Date: Wed, 26 Oct 2016 10:11:09 +0800

> This patch updates skb->protocol to ETH_P_IPV6 in ip6_tnl_xmit() when an
> IPv6 header is installed to a socket buffer.
> 
> This is not a cosmetic change.  Without updating this value, GSO packets
> transmitted through an ipip6 tunnel have the protocol of ETH_P_IP and
> skb_mac_gso_segment() will attempt to call gso_segment() for IPv4,
> which results in the packets being dropped.
> 
> Fixes: b8921ca83eed ("ip4ip6: Support for GSO/GRO")
> Signed-off-by: Eli Cooper <elicooper@gmx.com>

Applied and queued up for -stable, thank you.
