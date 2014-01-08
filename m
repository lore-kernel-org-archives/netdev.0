From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V3 1/3] net: Add GRO support for UDP encapsulating
 protocols
Date: Wed, 8 Jan 2014 22:39:15 +0200
Message-ID: <52CDB773.6030701@mellanox.com>
References: <1389213278-2200-1-git-send-email-ogerlitz@mellanox.com> <1389213278-2200-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<yanb@mellanox.com>, <shlomop@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: <hkchu@google.com>, <edumazet@google.com>,
	<herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:35470 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757774AbaAHUjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 15:39:24 -0500
In-Reply-To: <1389213278-2200-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2014 22:34, Or Gerlitz wrote:
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -13,6 +13,16 @@
>   #include <linux/skbuff.h>
>   #include <net/udp.h>
>   #include <net/protocol.h>
> +/*
> +struct udp_offload {
> +	__be16			 port;
> +	struct offload_callbacks callbacks;
> +	struct list_head	 list;
> +};
> +*/
sorry for this small mess, will clean it up
