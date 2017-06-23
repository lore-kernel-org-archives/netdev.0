From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2017-06-23
Date: Fri, 23 Jun 2017 14:11:54 -0400 (EDT)
Message-ID: <20170623.141154.1049063599656855226.davem@davemloft.net>
References: <1498201594-10835-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35006 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753786AbdFWSMC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 14:12:02 -0400
In-Reply-To: <1498201594-10835-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 23 Jun 2017 09:06:28 +0200

> 1) Fix xfrm garbage collecting when unregistering a netdevice.
>    From Hangbin Liu.
> 
> 2) Fix NULL pointer derefernce when exiting a network namespace.
>    From Hangbin Liu.
> 
> 3) Fix some error codes in pfkey to prevent a NULL pointer derefernce.
>    From Dan Carpenter.
> 
> 4) Fix NULL pointer derefernce on allocation failure in pfkey.
>    From Dan Carpenter.
> 
> 5) Adjust IPv6 payload_len to include extension headers. Otherwise
>    we corrupt the packets when doing ESP GRO on transport mode.
>    From Yossi Kuperman.
> 
> 6) Set nhoff to the proper offset of the IPv6 nexthdr when doing ESP GRO.
>    From Yossi Kuperman.
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen!
