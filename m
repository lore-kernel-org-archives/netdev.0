From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] Netfilter fixes for net
Date: Fri, 09 May 2014 13:17:58 -0400 (EDT)
Message-ID: <20140509.131758.403206154033471633.davem@davemloft.net>
References: <1399632967-4423-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1399632967-4423-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri,  9 May 2014 12:56:01 +0200

> The following batch contains netfilter fixes for your net tree, they are:
> 
> 1) Fix use after free in nfnetlink when sending a batch for some
>    unsupported subsystem, from Denys Fedoryshchenko.
> 
> 2) Skip autoload of the nat module if no binding is specified via
>    ctnetlink, from Florian Westphal.
> 
> 3) Set local_df after netfilter defragmentation to avoid a bogus ICMP
>    fragmentation needed in the forwarding path, also from Florian.
> 
> 4) Fix potential user after free in ip6_route_me_harder() when returning
>    the error code to the upper layers, from Sergey Popovich.
> 
> 5) Skip possible bogus ICMP time exceeded emitted from the router (not
>    valid according to RFC) if conntrack zones are used, from Vasily Averin.
> 
> 6) Fix fragment handling when nf_defrag_ipv4 is loaded but nf_conntrack
>    is not present, also from Vasily.

Pulled, thanks a lot Pablo.
