From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] udp_tunnel: Only build ip6_udp_tunnel.c when IPV6
 is selected
Date: Sat, 20 Sep 2014 21:38:14 -0400 (EDT)
Message-ID: <20140920.213814.1639075278770502877.davem@davemloft.net>
References: <1411174973-323-1-git-send-email-azhou@nicira.com>
	<20140919.220620.557633612726378260.davem@davemloft.net>
	<CA+mtBx-U+198m671ebOZikiQhT3fEBOSQK6My7SNZ4DtPJCuAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: azhou@nicira.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418AbaIUBiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 21:38:19 -0400
In-Reply-To: <CA+mtBx-U+198m671ebOZikiQhT3fEBOSQK6My7SNZ4DtPJCuAQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sat, 20 Sep 2014 16:14:47 -0700

> On Fri, Sep 19, 2014 at 7:06 PM, David Miller <davem@davemloft.net> wrote:
>> From: Andy Zhou <azhou@nicira.com>
>> Date: Fri, 19 Sep 2014 18:02:53 -0700
>>
>>> Functions supplied in ip6_udp_tunnel.c are only needed when IPV6 is
>>> selected. When IPV6 is not selected, those functions are stubbed out
>>> in udp_tunnel.h.
>>>
>>> ==================================================================
>>>  net/ipv6/ip6_udp_tunnel.c:15:5: error: redefinition of 'udp_sock_create6'
>>>      int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
>>>  In file included from net/ipv6/ip6_udp_tunnel.c:9:0:
>>>       include/net/udp_tunnel.h:36:19: note: previous definition of 'udp_sock_create6' was here
>>>        static inline int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
>>> ==================================================================
>>>
>>> Fixes:  fd384412e udp_tunnel: Seperate ipv6 functions into its own file
>>> Reported-by: kbuild test robot <fengguang.wu@intel.com>
>>> Signed-off-by: Andy Zhou <azhou@nicira.com>
>>
>> Applied, thanks Andy.
> 
> David, what branch did you apply this to? I pulled from your net-next
> but don't see this patch...

The one I didn't push from my workstation yet, oops :-)

It should be there now, sorry about that.
