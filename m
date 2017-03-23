From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] net: Add sysctl to toggle early demux for
 tcp and udp
Date: Wed, 22 Mar 2017 21:40:36 -0700 (PDT)
Message-ID: <20170322.214036.1157623192132988457.davem@davemloft.net>
References: <20170322.194357.531371967824197040.davem@davemloft.net>
        <20170322.203618.972117086361436133.davem@davemloft.net>
        <8d5e22e0bd21739b1d4ea21703ffde7d@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        stephen@networkplumber.org, tom@herbertland.com
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47764 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751792AbdCWElD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 00:41:03 -0400
In-Reply-To: <8d5e22e0bd21739b1d4ea21703ffde7d@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Wed, 22 Mar 2017 21:55:04 -0600

>> This doesn't build with ipv6 as a module:
>> net/built-in.o: In function `proc_tcp_early_demux':
>> sysctl_net_ipv4.c:(.text+0x145cfc): undefined reference to
>> `tcp_v6_early_demux_configure'
>> net/built-in.o: In function `proc_udp_early_demux':
>> sysctl_net_ipv4.c:(.text+0x145d4c): undefined reference to
>> `udp_v6_early_demux_configure'
>> Makefile:983: recipe for target 'vmlinux' failed
> 
> Hi David
> 
> Sorry about that (we always have IPV6 enabled).
> Do I have to send a v5 or separate patch for this?

Please send a v5, thanks.
