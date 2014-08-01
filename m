From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: fix the counter
 ICMP_MIB_INERRORS/ICMP6_MIB_INERRORS
Date: Thu, 31 Jul 2014 22:04:38 -0700 (PDT)
Message-ID: <20140731.220438.1984870938307560536.davem@davemloft.net>
References: <53D75922.2090106@cn.fujitsu.com>
	<53DA1258.90203@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54277 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbaHAFEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 01:04:39 -0400
In-Reply-To: <53DA1258.90203@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Thu, 31 Jul 2014 17:54:32 +0800

> 
> When dealing with ICMPv[46] Error Message, function icmp_socket_deliver()
> and icmpv6_notify() do some valid checks on packet's length, but then some
> protocols check packet's length redaudantly. So remove those duplicated
> statements, and increase counter ICMP_MIB_INERRORS/ICMP6_MIB_INERRORS in
> function icmp_socket_deliver() and icmpv6_notify() respectively.
> 
> In addition, add missed counter in udp6/udplite6 when socket is NULL.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---
> 
> v2: remove nested rcu_read_lock from icmpv6_notify

Applied to net-next, thanks.
