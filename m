From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: reuse ip6_frag_id from ip6_ufo_append_data
Date: Sat, 22 Feb 2014 00:28:55 -0500 (EST)
Message-ID: <20140222.002855.2055879239461145413.davem@davemloft.net>
References: <20140221015535.GB28822@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbaBVF2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 00:28:51 -0500
In-Reply-To: <20140221015535.GB28822@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 21 Feb 2014 02:55:35 +0100

> Currently we generate a new fragmentation id on UFO segmentation. It
> is pretty hairy to identify the correct net namespace and dst there.
> Especially tunnels use IFF_XMIT_DST_RELEASE and thus have no skb_dst
> available at all.
> 
> This causes unreliable or very predictable ipv6 fragmentation id
> generation while segmentation.
> 
> Luckily we already have pregenerated the ip6_frag_id in
> ip6_ufo_append_data and can use it here.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks Hannes.
