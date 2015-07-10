From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Nonlocal bind
Date: Thu, 09 Jul 2015 21:09:33 -0700 (PDT)
Message-ID: <20150709.210933.1879950273189399588.davem@davemloft.net>
References: <1436399902-3049471-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47415 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbbGJEJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 00:09:34 -0400
In-Reply-To: <1436399902-3049471-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 8 Jul 2015 16:58:22 -0700

> Add support to allow non-local binds similar to how this was done for IPv4.
> Non-local binds are very useful in emulating the Internet in a box, etc.
> 
> This add the ip_nonlocal_bind sysctl under ipv6.
> 
> Testing:
> 
> Set up nonlocal binding and receive routing on a host, e.g.:
> 
> ip -6 rule add from ::/0 iif eth0 lookup 200
> ip -6 route add local 2001:0:0:1::/64 dev lo proto kernel scope host table 200
> sysctl -w net.ipv6.ip_nonlocal_bind=1
> 
> Set up routing to 2001:0:0:1::/64 on peer to go to first host
> 
> ping6 -I 2001:0:0:1::1 peer-address -- to verify
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

This seems reasonable, applied, thanks Tom.
