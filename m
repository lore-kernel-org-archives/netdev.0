From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH v2] net: fix the counter ICMP_MIB_INERRORS/ICMP6_MIB_INERRORS
Date: Fri, 1 Aug 2014 09:09:17 +0800
Message-ID: <53DAE8BD.30907@cn.fujitsu.com>
References: <53D75922.2090106@cn.fujitsu.com>	 <53DA1258.90203@cn.fujitsu.com> <1406840726.13603.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:18077 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750977AbaHABJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 21:09:34 -0400
In-Reply-To: <1406840726.13603.3.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2014 05:05 AM, Hannes Frederic Sowa wrote:
> On Do, 2014-07-31 at 17:54 +0800, Duan Jiong wrote:
>> When dealing with ICMPv[46] Error Message, function icmp_socket_deliver()
>> and icmpv6_notify() do some valid checks on packet's length, but then some
>> protocols check packet's length redaudantly. So remove those duplicated
>> statements, and increase counter ICMP_MIB_INERRORS/ICMP6_MIB_INERRORS in
>> function icmp_socket_deliver() and icmpv6_notify() respectively.
>>
>> In addition, add missed counter in udp6/udplite6 when socket is NULL.
>>
>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>> ---
>>
>> v2: remove nested rcu_read_lock from icmpv6_notify
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> IPv4 handler can also be cleaned up. ;)

Ok, i will make another patch soon. :)

Thanks,
  Duan

> 
> Thanks!
> 
> 
