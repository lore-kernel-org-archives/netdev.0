From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net-next 01/15] net: introduce keepalive function in
 struct proto
Date: Fri, 25 Nov 2016 20:41:38 -0500 (EST)
Message-ID: <20161125.204138.170049617838570584.davem@davemloft.net>
References: <20161124150645.90881-1-ubraun@linux.vnet.ibm.com>
        <20161124150645.90881-2-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        utz.bacher@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58700 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752461AbcKZBlm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 20:41:42 -0500
In-Reply-To: <20161124150645.90881-2-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Thu, 24 Nov 2016 16:06:31 +0100

> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index 3ea1cf8..9b1602a 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -617,6 +617,7 @@ void tcp_set_keepalive(struct sock *sk, int val)
>  	else if (!val)
>  		inet_csk_delete_keepalive_timer(sk);
>  }
> +EXPORT_SYMBOL(tcp_set_keepalive);

Please use EXPORT_SYMBOL_GPL().
