From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: allocate more headroom in incoming
 skbs
Date: Thu, 26 Jan 2012 13:51:51 -0500 (EST)
Message-ID: <20120126.135151.240209789181199723.davem@davemloft.net>
References: <1327499790.2425.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ian.Campbell@citrix.com,
	vasundhara.volam@emulex.com, sathya.perla@emulex.com,
	ajit.khaparde@emulex.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045Ab2AZSv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 13:51:58 -0500
In-Reply-To: <1327499790.2425.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Jan 2012 14:56:30 +0100

> Allocation of 64 bytes in skb headroom is not enough if we have to pull
> ethernet + ipv6 + tcp headers, and/or extra tunneling header.
> 
> Its currently not noticed because netdev_alloc_skb_ip_align(64) give us
> more room, thanks to power-of-two kmalloc() roundups.
> 
> Make sure we ask for 128 bytes so that side effects of upcoming patches
> from Ian Campbell dont decrease benet rx performance, because of extra
> skb head reallocations.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
