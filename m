From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next 0/4] Use IS_ERR_OR_NULL().
Date: Tue, 22 Jan 2013 20:44:38 -0500
Message-ID: <CAP=VYLpyEXcZ9N6jHSvnbL+ZyRY_eyRdesqn6Dpm-6P=BPDaBQ@mail.gmail.com>
References: <50FEBF1E.6070209@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:52713 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752729Ab3AWBpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 20:45:11 -0500
Received: by mail-wg0-f51.google.com with SMTP id 8so3081994wgl.6
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 17:45:09 -0800 (PST)
In-Reply-To: <50FEBF1E.6070209@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 22, 2013 at 11:32 AM, YOSHIFUJI Hideaki
<yoshfuji@linux-ipv6.org> wrote:
> YOSHIFUJI Hideaki (4):
>   net: Use IS_ERR_OR_NULL().
>   ipv4: Use IS_ERR_OR_NULL().
>   ipv6: Use IS_ERR_OR_NULL().
>   netfilter: Use IS_ERR_OR_NULL().
>
>  net/core/flow.c                 |    2 +-
>  net/ipv4/af_inet.c              |    2 +-
>  net/ipv4/netfilter/arp_tables.c |   10 +++++-----
>  net/ipv4/netfilter/ip_tables.c  |   10 +++++-----
>  net/ipv4/tcp.c                  |    2 +-
>  net/ipv4/udp.c                  |    2 +-
>  net/ipv6/addrconf.c             |    4 ++--
>  net/ipv6/netfilter/ip6_tables.c |   10 +++++-----
>  8 files changed, 21 insertions(+), 21 deletions(-)

Just as a heads-up, there are discussions underway about
whether the whole IS_ERR_OR_NULL interface is one that
we want to be adding more users to:

https://patchwork.kernel.org/patch/1953271/

Paul.
--

>
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
