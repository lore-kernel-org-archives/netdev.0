From: David Miller <davem@davemloft.net>
Subject: Re: UDP sockets oddities
Date: Fri, 25 Aug 2017 21:19:05 -0700 (PDT)
Message-ID: <20170825.211905.920493778125075310.davem@davemloft.net>
References: <1503712322.11498.12.camel@edumazet-glaptop3.roam.corp.google.com>
        <354e6c3a-1771-e8a7-24dd-1b70266563af@gmail.com>
        <1503718844.11498.19.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, pabeni@redhat.com,
        willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41764 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750777AbdHZETG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 00:19:06 -0400
In-Reply-To: <1503718844.11498.19.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 25 Aug 2017 20:40:44 -0700

> On Fri, 2017-08-25 at 20:25 -0700, Florian Fainelli wrote:
> 
>> It would. Since the call trace involves udp_send_skb() how come we are
>> not returning an error to write(2)? are there other code paths where the
>> neighbor code can do drops like these?
> 
> Are you suggesting write(2) should block until ARP resolution is
> done ? :)
> 
> What about non blocking writes ?
> 
> Honestly UDP is not a protocol for which we must absolutely be sure
> packets are sent or not.

Agreed, but the ARP resolution queue really needs to scale it's backlog
to the physical technology it is attached to.
