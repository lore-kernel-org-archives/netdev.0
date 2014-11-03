From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] ipv6: Fix iflink setting for ipv6 tunnels
Date: Mon, 03 Nov 2014 15:43:05 -0500 (EST)
Message-ID: <20141103.154305.242200539181988126.davem@davemloft.net>
References: <1415002770-5797-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772AbaKCUnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 15:43:08 -0500
In-Reply-To: <1415002770-5797-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 3 Nov 2014 09:19:26 +0100

> The ipv6 tunnels do the dev->iflink setting too early, it gets
> overwritten by register_netdev(). So set dev->iflink from within
> a ndo_init function to keep the configured setting.
> 
> This patchset fixes this for ip6_tunnel, vti6, sit and gre6.

Series applied, good catch, and thanks for checking all of the ipv6
tunnel drivers for this problem.
