From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: introduce skb_transport_header_was_set()
Date: Tue, 08 Jan 2013 17:52:09 -0800 (PST)
Message-ID: <20130108.175209.183446498109754610.davem@davemloft.net>
References: <1356104720.21834.7497.camel@edumazet-glaptop>
	<50D5B8BA.9010808@mojatatu.com>
	<1357586901.6919.3551.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756193Ab3AIBwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 20:52:10 -0500
In-Reply-To: <1357586901.6919.3551.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 07 Jan 2013 11:28:21 -0800

> [PATCH net-next] net: introduce skb_transport_header_was_set()
> 
> We have skb_mac_header_was_set() helper to tell if mac_header
> was set on a skb. We would like the same for transport_header.
> 
> __netif_receive_skb() doesn't reset the transport header if already
> set by GRO layer.
> 
> Note that network stacks usually reset the transport header anyway,
> after pulling the network header, so this change only allows
> a followup patch to have more precise qdisc pkt_len computation
> for GSO packets at ingress side.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
