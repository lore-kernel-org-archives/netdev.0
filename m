From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: support IPV6_PMTU_INTERFACE on sockets
Date: Wed, 18 Dec 2013 17:37:19 -0500 (EST)
Message-ID: <20131218.173719.1100495894522610541.davem@davemloft.net>
References: <20131215024114.GA1442@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57308 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090Ab3LRWhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 17:37:21 -0500
In-Reply-To: <20131215024114.GA1442@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 15 Dec 2013 03:41:14 +0100

> IPV6_PMTU_INTERFACE is the same as IPV6_PMTU_PROBE for ipv6. Add it
> nontheless for symmetry with IPv4 sockets. Also drop incoming MTU
> information if this mode is enabled.
> 
> The additional bit in ipv6_pinfo just eats in the padding behind the
> bitfield. There are no changes to the layout of the struct at all.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

This looks fine, applied, thanks.
