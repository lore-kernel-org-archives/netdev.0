From: Erik Nordmark <nordmark@sonic.net>
Subject: Re: [PATCH net v2] ipv6: Allow IPv4-mapped address as next-hop
Date: Mon, 5 Dec 2016 22:08:05 -0800
Message-ID: <5aaea431-23cc-e68a-9008-f8861e00faac@sonic.net>
References: <1480827429-22259-1-git-send-email-nordmark@arista.com>
 <20161205.145223.1574324293082144579.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gilligan@arista.com
To: David Miller <davem@davemloft.net>, nordmark@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from c.mail.sonic.net ([64.142.111.80]:33004 "EHLO c.mail.sonic.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751677AbcLFGIP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 01:08:15 -0500
In-Reply-To: <20161205.145223.1574324293082144579.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/5/16 11:52 AM, David Miller wrote:
> From: Erik Nordmark <nordmark@arista.com>
> Date: Sat,  3 Dec 2016 20:57:09 -0800
>
>> Made kernel accept IPv6 routes with IPv4-mapped address as next-hop.
>>
>> It is possible to configure IP interfaces with IPv4-mapped addresses, and
>> one can add IPv6 routes for IPv4-mapped destinations/prefixes, yet prior
>> to this fix the kernel returned an EINVAL when attempting to add an IPv6
>> route with an IPv4-mapped address as a nexthop/gateway.
>>
>> RFC 4798 (a proposed standard RFC) uses IPv4-mapped addresses as nexthops,
>> thus in order to support that type of address configuration the kernel
>> needs to allow IPv4-mapped addresses as nexthops.
>>
>> Signed-off-by: Erik Nordmark <nordmark@arista.com>
>> Signed-off-by: Bob Gilligan <gilligan@arista.com>
> Applied to net-next, thanks.
>
Thanks, especially for moving it from net to net-next.

I guess I don't fully understand what is considered a bug fix for net as 
opposed to new stuff for net-next. Is the former mostly for regressions 
and serious bugs? This was a fix for a bug that's been there since the 
beginning of IPv6 time AFAICT.


   Erik
