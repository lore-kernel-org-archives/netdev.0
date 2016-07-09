From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: do not abuse GFP_ATOMIC in
 inet6_netconf_notify_devconf()
Date: Sat, 09 Jul 2016 18:14:53 -0400 (EDT)
Message-ID: <20160709.181453.1096296102970406166.davem@davemloft.net>
References: <1467946591.1273.45.camel@edumazet-glaptop3.roam.corp.google.com>
	<1467947904.1273.56.camel@edumazet-glaptop3.roam.corp.google.com>
	<1467949564.1273.61.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: masashi.honma@gmail.com, netdev@vger.kernel.org,
	nicolas.dichtel@6wind.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38768 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933047AbcGIWOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 18:14:54 -0400
In-Reply-To: <1467949564.1273.61.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Jul 2016 05:46:04 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> All inet6_netconf_notify_devconf() callers are in process context,
> so we can use GFP_KERNEL allocations if we take care of not holding
> a rwlock while not needed in ip6mr (we hold RTNL there)
> 
> 
> Fixes: d67b8c616b48 ("netconf: advertise mc_forwarding status")
> Fixes: f3a1bfb11ccb ("rtnl/ipv6: use netconf msg to advertise forwarding status")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
