From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net-next] net ipv6: Remove rebundant rt6i_nsiblings
 initialization
Date: Thu, 11 Jul 2013 09:32:09 +0200
Message-ID: <51DE5F79.7080202@6wind.com>
References: <1373502442-32403-1-git-send-email-fan.du@windriver.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, jmorris@namei.org, kuznet@ms2.inr.ac.ru,
	davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:36001 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755644Ab3GKHcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 03:32:12 -0400
Received: by mail-wg0-f44.google.com with SMTP id m15so6679278wgh.23
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 00:32:11 -0700 (PDT)
In-Reply-To: <1373502442-32403-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/07/2013 02:27, Fan Du a =C3=A9crit :
> Seting rt->rt6i_nsiblings to zero is rebundant, because above memset
> has zeroed the rest of rt excluding the first dst memember.
>
> Signed-off-by: Fan Du <fan.du@windriver.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

> ---
>   net/ipv6/route.c |    1 -
>   1 files changed, 0 insertions(+), 1 deletions(-)
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 7ca87b3..b88f99f 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -278,7 +278,6 @@ static inline struct rt6_info *ip6_dst_alloc(stru=
ct net *net,
>   		rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.peers);
>   		rt->rt6i_genid =3D rt_genid(net);
>   		INIT_LIST_HEAD(&rt->rt6i_siblings);
> -		rt->rt6i_nsiblings =3D 0;
>   	}
>   	return rt;
>   }
>
