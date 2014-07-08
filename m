From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] net: Improvements and applications of packet flow
 hash in transmit path
Date: Mon, 07 Jul 2014 21:18:18 -0700 (PDT)
Message-ID: <20140707.211818.1347035145310620241.davem@davemloft.net>
References: <alpine.DEB.2.02.1407012056320.26744@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48728 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219AbaGHEST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 00:18:19 -0400
In-Reply-To: <alpine.DEB.2.02.1407012056320.26744@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 1 Jul 2014 21:31:55 -0700 (PDT)

> This patch series includes some patches which improve and make use
> of skb->hash in the transmit path.
> 
> What is included:
> 
> - Infrastructure to save a precomputed hash in the sock structure.
>   For connected TCP and UDP sockets we only need to compute the
>   flow hash once and not once for every packet.
> - Call skb_get_hash in get_xps_queue and __skb_tx_hash. This eliminates
>   the awkward access to skb->sk->sk_hash in the lower transmit path.
> - Move UDP source port generation into a common function in udp.h This
>   implementation is mostly based on vxlan_src_port.
> - Use non-zero IPv6 flow labels in flow_dissector as port information
>   for flow hash calculation.
> - Implement automatic flow label generation on transmit (per RFC 6438).
> - Don't repeatedly try to compute an L4 hash in skb_get_hash if we've
>   already tried to find one in software stack calculation.

Series applied, thanks Tom.
