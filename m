From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] net: ipv4: fix sparse error in fib_good_nh()
Date: Thu, 18 Aug 2016 11:35:45 -0600
Message-ID: <bb00f2f2-7930-8e08-75c0-b98d8cc26db0@cumulusnetworks.com>
References: <1471540774.29842.76.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35014 "EHLO
        mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754414AbcHSCqO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 22:46:14 -0400
Received: by mail-pa0-f47.google.com with SMTP id i5so11396888pat.2
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 19:46:14 -0700 (PDT)
In-Reply-To: <1471540774.29842.76.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/18/16 11:19 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Fixes following sparse errors :
> 
> net/ipv4/fib_semantics.c:1579:61: warning: incorrect type in argument 2
> (different base types)
> net/ipv4/fib_semantics.c:1579:61:    expected unsigned int [unsigned]
> [usertype] key
> net/ipv4/fib_semantics.c:1579:61:    got restricted __be32 const
> [usertype] nh_gw
> 
> 
> Fixes: a6db4494d218c ("net: ipv4: Consider failed nexthops in multipath routes")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv4/fib_semantics.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)


Acked-by: David Ahern <dsa@cumulusnetworks.com>

Thanks, Eric.
