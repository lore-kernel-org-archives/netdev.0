From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next] udp_tunnel: Only build ip6_udp_tunnel.c when IPV6 is selected
Date: Sat, 20 Sep 2014 16:14:47 -0700
Message-ID: <CA+mtBx-U+198m671ebOZikiQhT3fEBOSQK6My7SNZ4DtPJCuAQ@mail.gmail.com>
References: <1411174973-323-1-git-send-email-azhou@nicira.com>
	<20140919.220620.557633612726378260.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Zhou <azhou@nicira.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:51615 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbaITXOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 19:14:48 -0400
Received: by mail-ig0-f180.google.com with SMTP id a13so948614igq.1
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 16:14:48 -0700 (PDT)
In-Reply-To: <20140919.220620.557633612726378260.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2014 at 7:06 PM, David Miller <davem@davemloft.net> wrote:
> From: Andy Zhou <azhou@nicira.com>
> Date: Fri, 19 Sep 2014 18:02:53 -0700
>
>> Functions supplied in ip6_udp_tunnel.c are only needed when IPV6 is
>> selected. When IPV6 is not selected, those functions are stubbed out
>> in udp_tunnel.h.
>>
>> ==================================================================
>>  net/ipv6/ip6_udp_tunnel.c:15:5: error: redefinition of 'udp_sock_create6'
>>      int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
>>  In file included from net/ipv6/ip6_udp_tunnel.c:9:0:
>>       include/net/udp_tunnel.h:36:19: note: previous definition of 'udp_sock_create6' was here
>>        static inline int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
>> ==================================================================
>>
>> Fixes:  fd384412e udp_tunnel: Seperate ipv6 functions into its own file
>> Reported-by: kbuild test robot <fengguang.wu@intel.com>
>> Signed-off-by: Andy Zhou <azhou@nicira.com>
>
> Applied, thanks Andy.

David, what branch did you apply this to? I pulled from your net-next
but don't see this patch...

Thanks,
Tom

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
