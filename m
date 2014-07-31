From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] net: fix the counter
 ICMP_MIB_INERRORS/ICMP6_MIB_INERRORS
Date: Thu, 31 Jul 2014 23:05:26 +0200
Message-ID: <1406840726.13603.3.camel@localhost>
References: <53D75922.2090106@cn.fujitsu.com>
	 <53DA1258.90203@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev <netdev@vger.kernel.org>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:33779 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751826AbaGaVFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 17:05:31 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway1.nyi.internal (Postfix) with ESMTP id 99FA2227B5
	for <netdev@vger.kernel.org>; Thu, 31 Jul 2014 17:05:28 -0400 (EDT)
In-Reply-To: <53DA1258.90203@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Do, 2014-07-31 at 17:54 +0800, Duan Jiong wrote:
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

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

IPv4 handler can also be cleaned up. ;)

Thanks!
