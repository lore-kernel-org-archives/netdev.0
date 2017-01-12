From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6 net-next] inet: drop ->bind_conflict
Date: Thu, 12 Jan 2017 14:56:40 -0500 (EST)
Message-ID: <20170112.145640.2151487482259137455.davem@davemloft.net>
References: <1484165171-19210-1-git-send-email-jbacik@fb.com>
        <1484166164-21250-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, kraigatgoog@gmail.com,
        eric.dumazet@gmail.com, tom@herbertland.com,
        netdev@vger.kernel.org, kernel-team@fb.com
To: jbacik@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55986 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750835AbdALT4t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 14:56:49 -0500
In-Reply-To: <1484166164-21250-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josef Bacik <jbacik@fb.com>
Date: Wed, 11 Jan 2017 15:22:40 -0500

> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 56d756e..dc07734 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -63,6 +63,7 @@
>  #include <linux/times.h>
>  #include <linux/slab.h>
>  
> +#include <net/addrconf.h>
>  #include <net/net_namespace.h>
>  #include <net/icmp.h>
>  #include <net/inet_hashtables.h>

I don't see what this has to do with this change.
