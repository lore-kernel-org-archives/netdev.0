From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] tls: Use correct sk->sk_prot for IPV6
Date: Fri, 11 Aug 2017 14:36:23 -0700 (PDT)
Message-ID: <20170811.143623.1591561982680569459.davem@davemloft.net>
References: <1502361196-127278-1-git-send-email-ilyal@mellanox.com>
        <1502361196-127278-4-git-send-email-ilyal@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davejwatson@fb.com, aviadye@mellanox.com,
        borisp@mellanox.com
To: ilyal@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60354 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753401AbdHKVg0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 17:36:26 -0400
In-Reply-To: <1502361196-127278-4-git-send-email-ilyal@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilya Lesokhin <ilyal@mellanox.com>
Date: Thu, 10 Aug 2017 13:33:16 +0300

> +#if IS_ENABLED(CONFIG_IPV6)
> +	build_protos(tls_prots[TLSV6], &tcpv6_prot);
> +#endif
>  

Have you tested this with CONFIG_TLS=m and CONFIG_IPV6=m?

I bet it doesn't link.

How about CONFIG_IPV6=m and CONFIG_TLS=y?  That won't
work either.

In fact TLS has no Kconfig dependency whatsoever on IPV6.
