From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: Export tcpv6_prot
Date: Fri, 11 Aug 2017 14:34:45 -0700 (PDT)
Message-ID: <20170811.143445.124248584829184365.davem@davemloft.net>
References: <1502361196-127278-1-git-send-email-ilyal@mellanox.com>
        <1502361196-127278-3-git-send-email-ilyal@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davejwatson@fb.com, aviadye@mellanox.com,
        borisp@mellanox.com
To: ilyal@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60330 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753747AbdHKVeq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 17:34:46 -0400
In-Reply-To: <1502361196-127278-3-git-send-email-ilyal@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilya Lesokhin <ilyal@mellanox.com>
Date: Thu, 10 Aug 2017 13:33:15 +0300

> From: Boris Pismenny <borisp@mellanox.com>
> 
> Want to be able to use these in TLS.
> 
> Signed-off-by: Boris Pismenny <borisp@mellanox.com>
> ---
>  net/ipv6/tcp_ipv6.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 2521690..e3a44a5 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1944,6 +1944,7 @@ struct proto tcpv6_prot = {
>  #endif
>  	.diag_destroy		= tcp_abort,
>  };
> +EXPORT_SYMBOL(tcpv6_prot);

EXPORT_SYMBOL_GPL() please.
