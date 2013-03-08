From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next] ipv6: ndisc: remove redundant check for !dev->addr_len
Date: Sat, 09 Mar 2013 01:31:53 +0900
Message-ID: <513A1279.3040105@linux-ipv6.org>
References: <85f9fbce9b5a6ccc4e75b05dab268076e0574abf.1362740080.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:60628 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933136Ab3CHQby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 11:31:54 -0500
In-Reply-To: <85f9fbce9b5a6ccc4e75b05dab268076e0574abf.1362740080.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf wrote:
> send_sllao is already initialized with the value of dev->addr_len
> 
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>  net/ipv6/ndisc.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 76ef435..2712ab2 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -610,8 +610,6 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
>  		}
>  	}
>  #endif
> -	if (!dev->addr_len)
> -		send_sllao = 0;
>  	if (send_sllao)
>  		optlen += ndisc_opt_addr_space(dev);
>  
> 
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
