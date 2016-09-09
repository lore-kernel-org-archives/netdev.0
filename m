From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: accept u8 in IP_TOS ancillary data
Date: Thu, 08 Sep 2016 17:46:27 -0700 (PDT)
Message-ID: <20160908.174627.1650810290451032959.davem@davemloft.net>
References: <1473310376.15733.26.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com, ffusco@redhat.com,
        maze@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43220 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751027AbcIIAq2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:46:28 -0400
In-Reply-To: <1473310376.15733.26.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 07 Sep 2016 21:52:56 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit f02db315b8d8 ("ipv4: IP_TOS and IP_TTL can be specified as
> ancillary data") Francesco added IP_TOS values specified as integer.
> 
> However, kernel sends to userspace (at recvmsg() time) an IP_TOS value
> in a single byte, when IP_RECVTOS is set on the socket.
> 
> It can be very useful to reflect all ancillary options as given by the
> kernel in a subsequent sendmsg(), instead of aborting the sendmsg() with
> EINVAL after Francesco patch.
> 
> So this patch extends IP_TOS ancillary to accept an u8, so that an UDP
> server can simply reuse same ancillary block without having to mangle
> it.
> 
> Jesper can then augment
> https://github.com/netoptimizer/network-testing/blob/master/src/udp_example02.c
> to add TOS reflection ;)
> 
> Fixes: f02db315b8d8 ("ipv4: IP_TOS and IP_TTL can be specified as ancillary data")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
